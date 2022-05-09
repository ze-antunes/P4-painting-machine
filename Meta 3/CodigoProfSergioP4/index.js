import express from "express";
import ptp from "pdf-to-printer";

let printers = await ptp.getPrinters();

const app = express();
const port = 3000;

app.listen(port, () => {
    console.log(`PDF Printing Service listening on port ${port}`)
});



/*
const options = {
    printer: "HP Photosmart C4380 series",
    scale: "fit",
};
*/

function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}

app.get('/printers', async (req, res) => {
    return printers;
});


app.get('/print', async (req, res) => {
    
    try {
        let fileName = "data/" + req.query.name;
        console.log("imprimir " + fileName);
        await sleep(1000);
        var opts = {
            printer: req.query.printer,
            scale: req.query.scale
        }
        console.log(opts);
        await ptp.print("data/" + req.query.name, opts);
        res.status(200);
    }
    catch (error) {
        console.log("error: " + error);
    }
});

