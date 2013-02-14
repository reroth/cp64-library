package com.animation {
	
	import flash.display.Sprite;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ToolTip {
		
		private var _toolTipContainer:Sprite;
		
		public function ToolTip(addTo):void{
			
			//initialize the tooltips container
			_toolTipContainer = new Sprite();
			addTo.addChild(_toolTipContainer);
			
		}
		
		public function addToolTip(tipText:String, textFormat:TextFormat, w:int) {			
			
			while (_toolTipContainer.numChildren!=0){
				_toolTipContainer.removeChildAt(0);
			}
			
			var toolTipText:TextField = new TextField();
			_toolTipContainer.addChild(toolTipText);
			toolTipText.selectable = false;
			toolTipText.multiline = true;
			toolTipText.background = true;
			toolTipText.backgroundColor = 0x939393;
			toolTipText.border = true;
			toolTipText.htmlText = tipText;
			toolTipText.width = toolTipText.textWidth+20;
			toolTipText.setTextFormat(textFormat);
			
			var tipHeight:Array = new Array();
			tipHeight = tipText.split("<br>");
			toolTipText.height = 20*tipHeight.length;
			
			//make sure it won't go off the screen
			if (_toolTipContainer.mouseX+toolTipText.width/2 > w){
				toolTipText.x = w-toolTipText.width-1;
			}else{				
				toolTipText.x = _toolTipContainer.mouseX-toolTipText.width/2;
			}
			toolTipText.y = _toolTipContainer.mouseY-30;
			
		}
		
		public function removeToolTip() {
			
			while (_toolTipContainer.numChildren!=0){
				_toolTipContainer.removeChildAt(0);
			}
			
		}
	}
}