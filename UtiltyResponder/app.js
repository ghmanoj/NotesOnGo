
const express = require("express");
const {exec } = require("child_process")
const app = express();


const PORT = 8081;

app.get("/utility", async (req, res) => {
	console.log("Got request for logout");

	exec("shutdown /l", (error, stdout, stderr) => {
		if (error) {
			res.send({'message': 'error', 'status': false })
			return;
		}
		if (stderr) {
			res.send({'message': 'failed', 'status': false })
			return;
		}
		res.send({'message': 'Logout done', 'status': true })
	});
});

app.get("/uptime", async(req, res) => {
	console.log("Got request for uptime");

	exec("uptime", (error, stdout, stderr) => {
		if (error) {
			res.send({'message': 'Error in getting uptime', 'status': false })
			return;
		}
		if (stderr) {
			res.send({'message': 'Error in getting uptime', 'status': false })
			return;
		}
		res.send({'message': `${stdout}`, 'status': true })
	});
});


app.listen(PORT, () => {
	console.log(`Listening at api end point http://localhost:${PORT}`);
});
