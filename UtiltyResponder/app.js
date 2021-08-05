
const express = require("express");
const { exec } = require("child_process")
const app = express();

app.use(express.json())
app.use(express.urlencoded({extended: true}));


const PORT = 8081;

const availableCommands = {
	'utility:logout': 'shutdown /l',
	'utility:lock': 'shutdown /l',
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

	console.log(req.body);

	let message = req.body

	console.log(`Got request at /utilities_local, message: ${message}`);
	
	let cmd = getAppropriateCommand(message)

	if (cmd === undefined || cmd === null) {
		res.send({ 'message': 'Invalid command message', 'status': false })
		return;
	}

	executeAndRespond(cmd, res);
});


function executeAndRespond(cmd, res) {
	exec(cmd, (error, stdout, stderr) => {
		if (error) {
			res.send({ 'message': `${error}`, 'status': false })
			return;
		}
		if (stderr) {
			res.send({ 'message': `${stderr}`, 'status': false })
			return;
		}
		res.send({ 'message': `${stdout}`, 'status': true })
	});
}


app.listen(PORT, () => {
	console.log(`Listening at api end point http://localhost:${PORT}`);
});
