package rfcomponents.zother
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import rfcomponents.DataBase;
	import rfcomponents.event.DragEvent;

	public class DragHelp extends DataBase
	{
		protected var target:Sprite;
		protected var dragRect:Rectangle;
		protected var dict:Dictionary;
		public var stopDownEvent:Boolean;
		public function DragHelp(target:Sprite,rect:Rectangle = null)
		{
			this.target = target;
			setDragRect(rect);
			dict = new Dictionary
		}
		
		public function setDragRect(rect:Rectangle):void{
			this.dragRect = rect;
			if(!dragRect){
				return;
			}
		}
		
		public var xlock:Boolean;
		public var ylock:Boolean;
		
		protected var stage:Stage;
		protected var prex:int;
		protected var prey:int;
		public function bindDragTarget(drag:Sprite,rect:Rectangle = null):void{
			drag.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			if(rect){
				dict[drag] = rect;
			}
		}
		public function removeDragTarget(drag:Sprite):void{
			drag.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			dict[drag] = null;
			delete dict[drag];
		}
		
		protected function mouseDownHandler(event:MouseEvent):void{
			if(!_enabled){
				return;
			}
			
			if(stopDownEvent){
				event.stopImmediatePropagation();
			}
			
			var d:Sprite = event.currentTarget as Sprite;
			this.stage = d.stage;
			var rect:Rectangle = dict[d];
			if(rect){
				if(d.mouseX<rect.x || d.mouseX>rect.width || d.mouseY < rect.y || d.mouseY > rect.height){
					return;
				}
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			prex = target.mouseX;
			prey = target.mouseY;
			
			
			dispatchEvent(new DragEvent(DragEvent.DRAG_START,target));
		}
		
		public var dx:int;
		public var dy:int;
		protected var changeFlag:Boolean;
		protected function moveHandler(event:MouseEvent):void{
			var rect:Rectangle = target.getBounds(target);
			var left:Number = rect.left;
			var top:Number = rect.top
			dx = target.x + (target.mouseX-prex)*target.scaleX; 
			dy = target.y + (target.mouseY-prey) * target.scaleY;
			if(dragRect){
				if((dx + target.width + left)>dragRect.width){
					dx = dragRect.width - target.width - left;
				}else if(dx+left < dragRect.x){
					dx = dragRect.x-left
				}
				
				if((dy + target.height + top)>dragRect.height){
					dy = dragRect.height - target.height - top;
				}else if(dy+top < dragRect.y){
					dy = dragRect.y-top
				}
			}
			
			if(!xlock){
				target.x = dx;
			}
			if(!ylock){
				target.y = dy;
			}
			
			prex = target.mouseX;
			prey = target.mouseY;
			
			changeFlag = true;
			
			this.dispatchEvent(new Event(Event.CHANGE));
		//	event.updateAfterEvent();
		}
		
		protected function mouseUpHandler(event:MouseEvent):void{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			if(changeFlag){
				dispatchEvent(new DragEvent(DragEvent.DRAG_STOP,target));
			}
			changeFlag = false;
		}
	}
}