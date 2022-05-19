import express from "express";
import ptp from "pdf-to-printer";

const app = express();
const port = 3000;

const options = {
    printer: "EPSON BX300F Series",
    scale: "fit",
};

function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

app.get('/print', async (req, res) => {

    let fileName = "data/" + req.query.name;
    console.log("imprimir " + fileName);
    await sleep(1000);
    await ptp.print("data/" + req.query.name, options);
    res.status(200);
});

app.listen(port, () => {
    console.log(`PDF Printing Service listening on port ${port}`)
});