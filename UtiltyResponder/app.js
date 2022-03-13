const express = require("express");
const puppeteer = require('puppeteer');
const { exec } = require("child_process");

const app = express();

app.use(express.json())
app.use(express.urlencoded({extended: true}));


const PORT = 8081;

const USPS_USR = process.env.USPS_USR
const USPS_PW  = process.env.USPS_PW

let MailBoxCache = {};

const MAIL_COUNT_REGEX = /[\w]+\(([\d]+)\)/;

const availableCommands = {
    'help:command': {0: ''},
	'utility:logout': 'shutdown /l',
	'utility:lock': 'shutdown /l',
    'utility:mailbox': 'mailbox',
	'system:status': 'uptime'
}

function getAppropriateCommand(message) {
	let keys = Object.keys(message);
	let values = Object.values(message);

	if (keys.length !== 2 || values.length !== 2) {
		return undefined
	}

	let cmdPath = `${message['command']}:${message['modifier']}`;

	return availableCommands[cmdPath];
}

app.post("/utilities_local", async (req, res) => {
	let message = req.body
	console.log("Got request at /utilities_local, message: %j", message);
	
	let cmd = getAppropriateCommand(message)
	if (cmd === undefined || cmd === null) {
		res.send({'type':'Unknown', 'message': 'Invalid command message', 'status': false });
		return;
    } else {
        if (cmd === 'mailbox') {
            checkMailBoxAndRespond(res);
        } else {
            executeAndRespond(cmd, res);
        }
    }
});

function respondHelp(cmd, res) {
    res.send({'type':'help', 'message': cmd, 'status': true});
}

function checkMailBoxAndRespond(res) {
    let today = new Date().toISOString().slice(0,10);

    if (MailBoxCache[today]) {
        console.log("MailBox data exist: %j", today, JSON.stringify(MailBoxCache));
        parseAndRespond(res, today, MailBoxCache)
    } else {
        if (USPS_USR && USPS_PW) {
            (async () => {
                const browser = await puppeteer.launch({
                    headless: false,
                    executablePath: "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
                });
                const page = await browser.newPage();
                await page.goto('https://reg.usps.com/entreg/LoginAction_input?app=Phoenix&appURL=https://www.usps.com/');
                await page.type('#username', USPS_USR);
                await page.type('#password', USPS_PW);
                await page.click('#btn-submit');
                await page.waitForNavigation();
                await page.goto('https://informeddelivery.usps.com/box/pages/secure/DashboardAction_input.action?restart=1')
    
                let text = await page.evaluate(() => Array.from(document.querySelectorAll('#cp_week li'), element => element.textContent));
                text = text.map((value) => String(value.trim()));
                await browser.close();
    
                MailBoxCache[today] = text;

                parseAndRespond(res, today, MailBoxCache);
              })();
        } else {
            res.send({'type':'mailbox', 'message': 'Something is not right', 'status': false });
        }
    }
}

function parseAndRespond(res, key, map) {
    let mailsToday = map[key].filter((itm) => itm.startsWith("Today"));

    if (mailsToday != null) {
        var match = MAIL_COUNT_REGEX.exec(mailsToday);
        if (match != null) {
            res.send({'type':'mailbox', 'message': `USPS Mails Today: ${match[1]}`, 'status': true});
        } else {
            console.log(`Mails count match failed. ${mailsToday}`);
            res.send({'type':'mailbox', 'message': 'Something is not right', 'status': false});
        }
    } else {
        console.log("Mails today is null");
        res.send({'type':'mailbox', 'message': 'Something is not right.', 'status': false});
    }
}


function executeAndRespond(cmd, res) {
	exec(cmd, (error, stdout, stderr) => {
		if (error) {
			res.send({'type':'cmd', 'message': `${error}`, 'status': false });
			return;
		}
		if (stderr) {
			res.send({'type':'cmd', 'message': `${stderr}`, 'status': false });
			return;
		}
		res.send({'type':'cmd', 'message': `${stdout.trim()}`, 'status': true });
	});
}


app.listen(PORT, () => {
	console.log(`Listening at http://0.0.0.0:${PORT}`);
});
