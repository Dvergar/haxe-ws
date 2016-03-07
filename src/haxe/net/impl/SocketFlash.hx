package haxe.net.impl;

import flash.net.SecureSocket;
import haxe.io.Bytes;
import flash.utils.ByteArray;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.Event;
import flash.utils.Endian;
import flash.net.Socket;

class SocketFlash extends Socket2 {
    private var impl: Socket;

    public function new(host:String, port:Int, secure:Bool, debug:Bool = false) {
        super(host, port, debug);

        this.impl = secure ? new SecureSocket() : new Socket();
        this.impl.endian = Endian.BIG_ENDIAN;
        this.impl.addEventListener(flash.events.Event.CONNECT, function(e:Event) {
            this.onconnect();
        });
        this.impl.addEventListener(flash.events.Event.CLOSE, function(e:Event) {
            this.onclose();
        });
        this.impl.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
            this.onerror();
        });
        this.impl.addEventListener(flash.events.ProgressEvent.SOCKET_DATA, function(e:ProgressEvent) {
            var out = new ByteArray();
            impl.readBytes(out, 0, impl.bytesAvailable);
            this.ondata(Bytes.ofData(out));
        });

        this.impl.connect(host, port);
    }

    override public function close() {
        impl.close();
    }

    override public function send(data:Bytes) {
        impl.writeBytes(data.getData());
        impl.flush();
    }
}
