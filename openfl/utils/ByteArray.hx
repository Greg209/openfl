package openfl.utils; #if (!openfl_legacy || lime_hybrid)


import haxe.io.Bytes;
import haxe.io.BytesData;
import lime.utils.Bytes in LimeBytes;
import lime.utils.LZMA;
import openfl.errors.EOFError;

#if js
import js.html.ArrayBuffer;
#end

#if sys
import haxe.zip.Compress;
import haxe.zip.Uncompress;
#elseif format
import format.tools.Inflate;
#end

@:access(haxe.io.Bytes)
@:access(openfl.utils.ByteArrayData)
@:forward(bytesAvailable, endian, objectEncoding, position, clear, compress, deflate, inflate, readBoolean, readByte, readBytes, readDouble, readFloat, readInt, readMultiByte, readShort, readUnsignedByte, readUnsignedInt, readUnsignedShort, readUTF, readUTFBytes, toString, uncompress, writeBoolean, writeByte, writeBytes, writeDouble, writeFloat, writeInt, writeMultiByte, writeShort, writeUnsignedInt, writeUTF, writeUTFBytes)


abstract ByteArray(ByteArrayData) from ByteArrayData to ByteArrayData {
	
	
	public static var defaultObjectEncoding:UInt;
	
	public var length (get, set):Int;
	
	
	public inline function new (length:Int = 0):Void {
		
		#if flash
		this = new ByteArrayData ();
		this.length = length;
		#else
		this = new ByteArrayData (length);
		#end
		
	}
	
	
	@:arrayAccess @:noCompletion private inline function get (index:Int):Int {
		
		#if flash
		return this[index];
		#else
		return this.get (index);
		#end
		
	}
	
	
	@:arrayAccess @:noCompletion private inline function set (index:Int, value:Int):Int {
		
		#if flash
		this[index] = value;
		#else
		this.set (index, value);
		#end
		return value;
		
	}
	
	
	#if js
	@:from public static function fromArrayBuffer (buffer:ArrayBuffer):ByteArray {
		
		return ByteArrayData.fromBytes (Bytes.ofData (buffer));
		
	}
	#end
	
	
	@:from public static function fromBytes (bytes:Bytes):ByteArray {
		
		if (Std.is (bytes, ByteArrayData)) {
			
			return cast bytes;
			
		} else {
			
			#if flash
			return bytes.getData ();
			#else
			return ByteArrayData.fromBytes (bytes);
			#end
			
		}
		
	}
	
	
	@:from public static function fromBytesData (bytesData:BytesData):ByteArray {
		
		#if flash
		return bytesData;
		#else
		return ByteArrayData.fromBytes (Bytes.ofData (bytesData));
		#end
		
	}
	
	
	#if js
	@:to public static function toArrayBuffer (byteArray:ByteArray):ArrayBuffer {
		
		return (byteArray:ByteArrayData).getData ();
		
	}
	#end
	
	
	@:to @:noCompletion private static function toBytes (byteArray:ByteArray):Bytes {
		
		#if flash
		return Bytes.ofData (byteArray);
		#else
		return (byteArray:ByteArrayData);
		#end
		
	}
	
	
	@:to @:noCompletion private static function toBytesData (byteArray:ByteArray):BytesData {
		
		#if flash
		return byteArray;
		#else
		return (byteArray:ByteArrayData).getData ();
		#end
		
	}
	
	
	@:to @:noCompletion private static function toLimeBytes (byteArray:ByteArray):LimeBytes {
		
		#if flash
		return LimeBytes.ofData (byteArray);
		#else
		return new LimeBytes (byteArray.length, (byteArray:ByteArrayData).getData ());
		#end
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	@:noCompletion private function get_length ():Int {
		
		#if flash
		return this.length;
		#else
		return this.__length;
		#end
		
	}
	
	
	@:noCompletion private function set_length (value:Int):Int {
		
		#if flash
		this.length = value;
		#else
		if (value > 0) {
			
			this.__resize (value);
			
		}
		
		this.__length = value;
		#end
		
		return value;
		
	}
	
	
}


#if !flash


@:noCompletion @:dox(hide) class ByteArrayData extends Bytes implements IDataInput implements IDataOutput {
	
	
	public var bytesAvailable (get, never):Int;
	public var endian:Endian;
	public var objectEncoding:Int;
	public var position:Int;
	
	private var __length:Int;
	
	
	public function new (length:Int = 0) {
		
		var bytes = Bytes.alloc (length);
		
		#if js
		super (bytes.b.buffer);
		#else
		super (length, bytes.b);
		#end
		
		__length = length;
		endian = BIG_ENDIAN;
		position = 0;
		
	}
	
	
	public function clear ():Void {
		
		__length = 0;
		position = 0;
		
	}
	
	
	public function compress (algorithm:CompressionAlgorithm = null):Void {
		
		#if sys
		
		if (algorithm == null) {
			
			algorithm = CompressionAlgorithm.ZLIB;
			
		}
		
		if (algorithm == CompressionAlgorithm.LZMA) {
			
			__setData (LZMA.encode (this));
			
		} else {
			
			var windowBits = switch (algorithm) {
				
				case DEFLATE: -15;
				case GZIP: 31;
				default: 15;
				
			}
			
			#if enable_deflate
			__setData (Compress.run (this, 8, windowBits));
			#else
			__setData (Compress.run (this, 8));
			#end
			
		}
		
		#end
		
		__length = this.length;
		position = __length;
		
	}
	
	
	public function deflate ():Void {
		
		compress (CompressionAlgorithm.DEFLATE);
		
	}
	
	
	public static function fromBytes (bytes:Bytes):ByteArrayData {
		
		var result = new ByteArrayData ();
		result.__fromBytes (bytes);
		return result;
		
	}
	
	
	public function inflate () {
		
		uncompress (CompressionAlgorithm.DEFLATE);
		
	}
	
	
	public function readBoolean ():Bool {
		
		if (position < length) {
			
			return (get (position++) != 0);
			
		} else {
			
			throw new EOFError ();
			return false;
			
		}
		
	}
	
	
	public function readByte ():Int {
		
		var value = readUnsignedByte ();
		
		if (value & 0x80 != 0) {
			
			return value - 0x100;
			
		} else {
			
			return value;
			
		}
		
	}
	
	
	public function readBytes (bytes:ByteArray, offset:Int = 0, length:Int = 0):Void {
		
		if (length == 0) length = __length - position;
		
		if (position + length > __length) {
			
			throw new EOFError ();
			
		}
		
		if ((bytes:ByteArrayData).__length < offset + length) {
			
			(bytes:ByteArrayData).__resize (offset + length);
			
		}
		
		(bytes:ByteArrayData).blit (offset, this, position, length);
		position += length;
		
	}
	
	
	public function readDouble ():Float {
		
		if (position + 8 > __length) {
			
			throw new EOFError ();
			
		}
		
		position += 8;
		return getDouble (position - 8);
		
	}
	
	
	public function readFloat ():Float {
		
		if (position + 4 > __length) {
			
			throw new EOFError ();
			
		}
		
		position += 4;
		return getFloat (position - 4);
		
	}
	
	
	public function readInt ():Int {
		
		var ch1 = readUnsignedByte ();
		var ch2 = readUnsignedByte ();
		var ch3 = readUnsignedByte ();
		var ch4 = readUnsignedByte ();
		
		if (endian == LITTLE_ENDIAN) {
			
			return (ch4 << 24) | (ch3 << 16) | (ch2 << 8) | ch1;
			
		} else {
			
			return (ch1 << 24) | (ch2 << 16) | (ch3 << 8) | ch4;
			
		}
		
	}
	
	
	public function readMultiByte (length:Int, charSet:String):String {
		
		return readUTFBytes (length);
		
	}
	
	
	public function readShort ():Int {
		
		var ch1 = readUnsignedByte ();
		var ch2 = readUnsignedByte ();
		
		var value;
		
		if (endian == LITTLE_ENDIAN) {
			
			value = ((ch2 << 8) | ch1);
			
		} else {
			
			value = ((ch1 << 8) | ch2);
			
		}
		
		if ((value & 0x8000) != 0) {
			
			return value - 0x10000;
			
		} else {
			
			return value;
			
		}
		
	}
	
	
	public function readUnsignedByte ():Int {
		
		if (position < __length) {
			
			return get (position++);
			
		} else {
			
			throw new EOFError ();
			return 0;
			
		}
		
	}
	
	
	public function readUnsignedInt ():Int {
		
		var ch1 = readUnsignedByte ();
		var ch2 = readUnsignedByte ();
		var ch3 = readUnsignedByte ();
		var ch4 = readUnsignedByte ();
		
		if (endian == LITTLE_ENDIAN) {
			
			return (ch4 << 24) | (ch3 << 16) | (ch2 << 8) | ch1;
			
		} else {
			
			return (ch1 << 24) | (ch2 << 16) | (ch3 << 8) | ch4;
			
		}
		
	}
	
	
	public function readUnsignedShort ():Int {
		
		var ch1 = readUnsignedByte ();
		var ch2 = readUnsignedByte ();
		
		if (endian == LITTLE_ENDIAN) {
			
			return (ch2 << 8) + ch1;
			
		} else {
			
			return (ch1 << 8) | ch2;
			
		}
		
	}
	
	
	public function readUTF ():String {
		
		var bytesCount = readUnsignedShort ();
		return readUTFBytes (bytesCount);
		
	}
	
	
	public function readUTFBytes (length:Int):String {
		
		if (position + length > __length) {
			
			throw new EOFError ();
			
		}
		
		position += length;
		
		return getString (position - length, length);
		
	}
	
	
	public function uncompress (algorithm:CompressionAlgorithm = null):Void {
		
		#if sys
		
		if (algorithm == null) {
			
			algorithm = CompressionAlgorithm.GZIP;
			
		}
		
		if (algorithm == CompressionAlgorithm.LZMA) {
			
			__setData (LZMA.decode (this));
			
		} else {
			
			var windowBits = switch (algorithm) {
				
				case DEFLATE: -15;
				case GZIP: 31;
				default: 15;
				
			}
			
			#if enable_deflate
			__setData (Uncompress.run (this, null, windowBits));
			#else
			__setData (Uncompress.run (this, null));
			#end
			
		}
		
		#elseif format
		
		__setData (Inflate.run (this));
		
		#end
		
		__length = this.length;
		position = 0;
		
	}
	
	
	public function writeBoolean (value:Bool):Void {
		
		this.writeByte (value ? 1 : 0);
		
	}
	
	
	public function writeByte (value:Int):Void {
		
		__resize (position + 1);
		set (position++, value & 0xFF);
		
	}
	
	
	public function writeBytes (bytes:ByteArray, offset:UInt = 0, length:UInt = 0):Void {
		
		if (bytes.length == 0) return;
		if (length == 0) length = bytes.length - offset;
		
		__resize (position + length);
		blit (position, (bytes:ByteArrayData), offset, length);
		
		position += length;
		
	}
	
	
	public function writeDouble (value:Float):Void {
		
		__resize (position + 8);
		setDouble (position, value);
		position += 8;
		
	}
	
	
	public function writeFloat (value:Float):Void {
		
		__resize (position + 4);
		setFloat (position, value);
		position += 4;
		
	}
	
	
	public function writeInt (value:Int):Void {
		
		__resize (position + 4);
		
		if (endian == LITTLE_ENDIAN) {
			
			set (position++, value);
			set (position++, value >> 8);
			set (position++, value >> 16);
			set (position++, value >> 24);
			
		} else {
			
			set (position++, value >> 24);
			set (position++, value >> 16);
			set (position++, value >> 8);
			set (position++, value);
			
		}
		
	}
	
	
	public function writeMultiByte (value:String, charSet:String):Void {
		
		writeUTFBytes (value);
		
	}
	
	
	public function writeShort (value:Int):Void {
		
		__resize (position + 2);
		
		if (endian == LITTLE_ENDIAN) {
			
			set (position++, value);
			set (position++, value >> 8);
			
		} else {
			
			set (position++, value >> 8);
			set (position++, value);
			
		}
		
	}
	
	
	public function writeUnsignedInt (value:Int):Void {
		
		writeInt (value);
		
	}
	
	
	public function writeUTF (value:String):Void {
		
		var bytes = Bytes.ofString (value);
		
		writeShort (bytes.length);
		writeBytes (bytes);
		
	}
	
	
	public function writeUTFBytes (value:String):Void {
		
		var bytes = Bytes.ofString (value);
		writeBytes (Bytes.ofString (value));
		
	}
	
	
	private function __fromBytes (bytes:Bytes):Void {
		
		__setData (bytes);
		__length = bytes.length;
		
	}
	
	
	private function __resize (size:Int) {
		
		if (size > this.length) {
			
			var bytes = Bytes.alloc (((size + 1) * 3) >> 1);
			bytes.blit (0, this, 0, this.length);
			__setData (bytes);
			
		}
		
		if (__length < size) {
			
			__length = size;
			
		}
		
	}
	
	
	private inline function __setData (bytes:Bytes):Void {
		
		b = bytes.b;
		length = bytes.length;
		
		#if js
		data = bytes.data;
		#end
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	@:noCompletion private inline function get_bytesAvailable ():Int {
		
		return length - position;
		
	}
	
	
}


#else
typedef ByteArrayData = flash.utils.ByteArray;
#end
#else
typedef ByteArray = openfl._legacy.utils.ByteArray;
#end