const {
    app,
    Menu,
    BrowserWindow,
    ipcMain
} = require('electron');
const path = require('path');
const url = require('url');
const fs = require('fs');

const DRAMOPE = require('./dram_ope');
//IP Setting
const recvport = 0x4056;
const recvip = "0.0.0.0";
const port = 0x4000;
const ipaddr = "10.0.0.3";
const dramope = new DRAMOPE(ipaddr, port, recvip, recvport);
let mainWindow;


function createWindow() {
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    mainWindow.loadURL(url.format({
        pathname: path.join(__dirname, 'index.html'),
        protocol: 'file:',
        slashes: true
    }));

    // 開発ツールを有効化
    if(process.argv.length > 2 && process.argv[2] == "debug"){
        mainWindow.webContents.openDevTools();
    }

    Menu.setApplicationMenu(null);

    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    watchValue(dramope, "isopen", (v1, v2) => {
        console.log(`old:${v1}  new:${v2}`);
        mainWindow.webContents.send('isopen', v2);
    });

    //	dramope.close();
}

require('electron-reload')(__dirname, {
    electron: require(`${__dirname}/../node_modules/electron`)
});

app.on('ready', createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (mainWindow === null) {
        createWindow();
    }
});
/**
 * 値の変更を監視します
 * @param {Object} obj 監視対象のオブジェクト
 * @param {String} propName 監視対象のプロパティ名
 * @param {function(Object, Object)} func 値が変更された際に実行する関数
 */
function watchValue(obj, propName, func) {
    let value = obj[propName];
    Object.defineProperty(obj, propName, {
        get: () => value,
        set: newValue => {
            const oldValue = value;
            value = newValue;
            func(oldValue, newValue);
        },
        configurable: true
    });
}

const sleep = (time) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve();
        }, time);
    });
}

ipcMain.on("imgsend", (event, arg) => {
    let count = 0;
    let total = 0;
    const BUFF_SIZE = 256;
    let buf = new Buffer.from(arg);
    (async() => {
        console.log(buf);
        while (buf.length > total) {
            let size = (buf.length > total + BUFF_SIZE) ? BUFF_SIZE : buf.length - total;
            dramope.writeBinData(total / 4, buf.slice(total, total + size));
            total += size;
            count++;
            console.log(`count : ${count} byte: ${total} size${size}`);
            await sleep(0);
        }
        console.log("end");
    })();
});
ipcMain.on("isopen", (event, arg) => {
    mainWindow.webContents.send('isopen', dramope.isopen);
});
ipcMain.on("connect", (event, arg) => {
    console.log("open");
    dramope.open(arg.ip, arg.port, recvip, recvport);
});
ipcMain.on("disconn", (event, arg) => {
    console.log("close");
    dramope.close();
});
