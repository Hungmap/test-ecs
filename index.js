import  Express  from "express";
import os from "os";
const app = Express ();
app.get('/', (req, res) => {
    const containerip = req.socket.localAddress;
    const clienip = req.header('x-forwarded-for');
    const elbip = req.socket.remoteAddress;
    const hostname = os.hostname();
    console.log('Hello NodeJS from Project-network')
    res.json({
        serviceName : 'esc-demo1212331231241',
        contact: 'nguyenthanhhung021199@gmail.com',
        Cientip : clienip,
        ALB : elbip,
        Containerip : containerip,
        containerName: hostname,


    });
});
app.listen(9005,()=>{
    console.log("app stated successfully");
});
