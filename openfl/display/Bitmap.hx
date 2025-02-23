package openfl.display; #if (!display && !flash) #if !openfl_legacy


import openfl._internal.renderer.cairo.CairoBitmap;
import openfl._internal.renderer.canvas.CanvasBitmap;
import openfl._internal.renderer.dom.DOMBitmap;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl._internal.renderer.RenderSession;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if (js && html5)
import js.html.ImageElement;
#end


@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.geom.Rectangle)


class Bitmap extends DisplayObject {
	
	
	public var bitmapData:BitmapData;
	public var pixelSnapping:PixelSnapping;
	public var smoothing:Bool;
	
	#if (js && html5)
	private var __image:ImageElement;
	#end
	
	
	public function new (bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) {
		
		super ();
		
		this.bitmapData = bitmapData;
		this.pixelSnapping = pixelSnapping;
		this.smoothing = smoothing;
		
		if (pixelSnapping == null) {
			
			this.pixelSnapping = PixelSnapping.AUTO;
			
		}
		
	}
	
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		if (bitmapData != null) {
			
			var bounds = Rectangle.__temp;
			bounds.setTo (0, 0, bitmapData.width, bitmapData.height);
			bounds.__transform (bounds, matrix);
			
			rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
			
		}
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:InteractiveObject):Bool {
		
		if (!hitObject.visible || __isMask || bitmapData == null) return false;
		if (mask != null && !mask.__hitTestMask (x, y)) return false;
		
		__getWorldTransform ();
		
		var px = __worldTransform.__transformInverseX (x, y);
		var py = __worldTransform.__transformInverseY (x, y);
		
		if (px > 0 && py > 0 && px <= bitmapData.width && py <= bitmapData.height) {
			
			if (stack != null && !interactiveOnly) {
				
				stack.push (hitObject);
				
			}
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	private override function __hitTestMask (x:Float, y:Float):Bool {
		
		if (bitmapData == null) return false;
		
		__getWorldTransform ();
		
		var px = __worldTransform.__transformInverseX (x, y);
		var py = __worldTransform.__transformInverseY (x, y);
		
		if (px > 0 && py > 0 && px <= bitmapData.width && py <= bitmapData.height) {
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	public override function __renderCairo (renderSession:RenderSession):Void {
		
		CairoBitmap.render (this, renderSession);
		
	}
	
	
	public override function __renderCairoMask (renderSession:RenderSession):Void {
		
		renderSession.cairo.rectangle (0, 0, width, height);
		
	}
	
	
	public override function __renderCanvas (renderSession:RenderSession):Void {
		
		CanvasBitmap.render (this, renderSession);
		
	}
	
	
	public override function __renderCanvasMask (renderSession:RenderSession):Void {
		
		renderSession.context.rect (0, 0, width, height);
		
	}
	
	
	public override function __renderDOM (renderSession:RenderSession):Void {
		
		DOMBitmap.render (this, renderSession);
		
	}
	
	
	public override function __renderGL (renderSession:RenderSession):Void {
		
		if (__cacheAsBitmap) {
			__cacheGL(renderSession);
			return;
		}
		__preRenderGL (renderSession);
		GLBitmap.render (this, renderSession);
		__postRenderGL (renderSession);
		
	}
	
	
	public override function __updateMask (maskGraphics:Graphics):Void {
		
		maskGraphics.__commands.overrideMatrix (this.__worldTransform);
		maskGraphics.beginFill (0);
		maskGraphics.drawRect (0, 0, bitmapData.width, bitmapData.height);
		
		if (maskGraphics.__bounds == null) {
			
			maskGraphics.__bounds = new Rectangle ();
			
		}
		
		__getBounds (maskGraphics.__bounds, @:privateAccess Matrix.__identity);
		
		super.__updateMask (maskGraphics);
		
	}
	
	
	
	// Get & Set Methods
	
	
	
	
	private override function get_height ():Float {
		
		if (bitmapData != null) {
			
			return bitmapData.height * scaleY;
			
		}
		
		return 0;
		
	}
	
	
	private override function set_height (value:Float):Float {
		
		if (bitmapData != null) {
			
			if (value != bitmapData.height) {
				
				scaleY = value / bitmapData.height;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
	private override function get_width ():Float {
		
		if (bitmapData != null) {
			
			return bitmapData.width * scaleX;
			
		}
		
		return 0;
		
	}
	
	
	private override function set_width (value:Float):Float {
		
		if (bitmapData != null) {
			
			if (value != bitmapData.width) {
				
				scaleX = value / bitmapData.width;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
}


#else
typedef Bitmap = openfl._legacy.display.Bitmap;
#end
#else


/**
 * The Bitmap class represents display objects that represent bitmap images.
 * These can be images that you load with the <code>openfl.Assets</code> or 
 * <code>openfl.display.Loader</code> classes, or they can be images that you 
 * create with the <code>Bitmap()</code> constructor.
 *
 * <p>The <code>Bitmap()</code> constructor allows you to create a Bitmap
 * object that contains a reference to a BitmapData object. After you create a
 * Bitmap object, use the <code>addChild()</code> or <code>addChildAt()</code>
 * method of the parent DisplayObjectContainer instance to place the bitmap on
 * the display list.</p>
 *
 * <p>A Bitmap object can share its BitmapData reference among several Bitmap
 * objects, independent of translation or rotation properties. Because you can
 * create multiple Bitmap objects that reference the same BitmapData object,
 * multiple display objects can use the same complex BitmapData object without
 * incurring the memory overhead of a BitmapData object for each display
 * object instance.</p>
 *
 * <p>A BitmapData object can be drawn to the screen by a Bitmap object in one
 * of two ways: by using the default hardware renderer with a single hardware surface, 
 * or by using the slower software renderer when 3D acceleration is not available.</p>
 * 
 * <p>If you would prefer to perform a batch rendering command, rather than using a
 * single surface for each Bitmap object, you can also draw to the screen using the
 * <code>drawTiles()</code> or <code>drawTriangles()</code> methods which are
 * available to <code>openfl.display.Tilesheet</code> and <code>openfl.display.Graphics
 * objects.</code></p>
 *
 * <p><b>Note:</b> The Bitmap class is not a subclass of the InteractiveObject
 * class, so it cannot dispatch mouse events. However, you can use the
 * <code>addEventListener()</code> method of the display object container that
 * contains the Bitmap object.</p>
 */

#if flash
@:native("flash.display.Bitmap")
#end

extern class Bitmap extends DisplayObject {
	
	
	/**
	 * The BitmapData object being referenced.
	 */
	public var bitmapData:BitmapData;
	
	/**
	 * Controls whether or not the Bitmap object is snapped to the nearest pixel.
	 * This value is ignored in the native and HTML5 targets.
	 * The PixelSnapping class includes possible values:
	 * <ul>
	 *   <li><code>PixelSnapping.NEVER</code> - No pixel snapping occurs.</li>
	 *   <li><code>PixelSnapping.ALWAYS</code> - The image is always snapped to
	 * the nearest pixel, independent of transformation.</li>
	 *   <li><code>PixelSnapping.AUTO</code> - The image is snapped to the
	 * nearest pixel if it is drawn with no rotation or skew and it is drawn at a
	 * scale factor of 99.9% to 100.1%. If these conditions are satisfied, the
	 * bitmap image is drawn at 100% scale, snapped to the nearest pixel.
	 * When targeting Flash Player, this value allows the image to be drawn as fast 
	 * as possible using the internal vector renderer.</li>
	 * </ul>
	 */
	public var pixelSnapping:PixelSnapping;
	
	/**
	 * Controls whether or not the bitmap is smoothed when scaled. If
	 * <code>true</code>, the bitmap is smoothed when scaled. If
	 * <code>false</code>, the bitmap is not smoothed when scaled.
	 */
	public var smoothing:Bool;
	
	
	public function new (bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false);
	
	
}


#end