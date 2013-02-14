package com.animation {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.MovieClip;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	public class TemporalLegend {

		private var _binArray:Array;
		private var _tempControls:TemporalControls;
		private var _controls:Sprite;
		private var _stageWidth:int;
		private var _leftX:Number;
		private var _legendHeight:int;
		private var _legendContainer:Sprite;
		private var _xAxis:Sprite
		private var _xAxisLabels:Sprite;		
		private var _yMaxText:TextField;
		private var _textFormat:TextFormat;
		private var _toolTip:ToolTip;
		
		private var _inactiveColor:uint;		
		private var _activeColor:uint;
		private var _highlightColor:uint;
		private var _inactiveCT:ColorTransform;
		private var _activeCT:ColorTransform;
		private var _highlightCT:ColorTransform;
		
		public function TemporalLegend(tC:TemporalControls,controls:Sprite,xPos:Number,lHeight:int):void{
			
			//initialize the legend container
			_tempControls = tC;
			_controls = controls;
			_leftX = xPos + 1.5 * tC.BUTTON_FRAME_SIZE;
			_legendContainer = new Sprite();
			_controls.addChild(_legendContainer);
			_legendHeight=lHeight;
			var legendBottom:Number = _legendHeight-20;
			
			//intialize the colors
			_inactiveColor = _tempControls.getColor('inactive');
			_activeColor = _tempControls.getColor('active');
			_highlightColor = _tempControls.getColor('highlight');
			_inactiveCT = _tempControls.getCT('inactive');
			_activeCT = _tempControls.getCT('active');
			_highlightCT = _tempControls.getCT('highlight');
			
			//initialize the text style settings
			_textFormat = new TextFormat();
			_textFormat.font = "Trebuchet MS";
			_textFormat.bold = true;
			_textFormat.size = 12;
			_textFormat.color = _inactiveColor;
			
			//initialize the X Axis line
			_xAxis = new Sprite();
			_controls.addChildAt(_xAxis,4);
			_xAxis.graphics.lineStyle(1,_inactiveColor,.8);
			_xAxis.graphics.lineTo(_controls.width+2,0);
			_xAxis.x=_leftX-2;
			_xAxis.y=legendBottom+3.5;
			
			//initialize the Y Axis line
			var yAxis:Sprite = new Sprite();
			_controls.addChildAt(yAxis,5);
			yAxis.graphics.lineStyle(1,_inactiveColor,.8);
			yAxis.graphics.lineTo(0,legendBottom);
			yAxis.x=_leftX-2;
			yAxis.y=(legendBottom/2)-(legendBottom/2)+4;			
			
			//initialize the Y Axis maximum label
			_yMaxText = new TextField();
			_yMaxText.autoSize=TextFieldAutoSize.RIGHT;
			_yMaxText.selectable=false;			
			_yMaxText.x = _leftX-6;
			_yMaxText.y = -4;
			_controls.addChild(_yMaxText);
			
			//initialize the X Axis labels container
			_xAxisLabels = new Sprite();
			_controls.addChild(_xAxisLabels);
			_xAxisLabels.y = legendBottom;
			
			_toolTip = new ToolTip(_controls);		
			
		}
		
		public function drawHistogram(bA:Array,lA:Array,w:int):void {			
			
			_stageWidth = w;
			var legendWidth = _stageWidth-_leftX-20;
			_legendContainer.graphics.beginFill(0XFFFFFF,0);
			_legendContainer.graphics.drawRect(_leftX,0,legendWidth,_controls.height-10);
			_legendContainer.graphics.endFill();
						
			_xAxis.width = legendWidth			
			
			while (_legendContainer.numChildren!=0){
				_legendContainer.removeChildAt(0);
			}
			while (_xAxisLabels.numChildren!=0){
				_xAxisLabels.removeChildAt(0);
			}			
			
			_binArray = bA;
			var binCount:int = _binArray.length;
			var barWidth:int = Math.round((((legendWidth)-((binCount)*2))/binCount));
		
			var frequencyArray:Array = new Array(binCount);
			var dummyFrequencyArray:Array = new Array(binCount);
			
			for (var i:int=0; i<binCount; i++){								
				frequencyArray[i]=_binArray[i].length;
				dummyFrequencyArray[i]=_binArray[i].length;
			}
			
			dummyFrequencyArray.sort(Array.NUMERIC)
			var maximumFrequency:int=dummyFrequencyArray[dummyFrequencyArray.length-1];
			
			_controls.addChild(_yMaxText);
			_yMaxText.text = "Max: " + maximumFrequency.toString();
			_yMaxText.setTextFormat(_textFormat);
			
			for (var j:int=0; j<binCount; j++){						
				var barHeight:int=((frequencyArray[j]/maximumFrequency)*(_legendHeight-20))+1;				
				var barX:int=_leftX+(j*(barWidth+2));
				addBar(barWidth,barHeight,barX,j+1,lA[j].toString());
			}
			
			//Why doesn't this work?
			//changeBarColor(_tempControls.getAnimationIndex(),'active');
			
		}
		
		public function addBar(barWidth:int,barHeight:int,barX:int,j:int,xLabel:String):void {
	
			var barClip:MovieClip = new MovieClip();
			_legendContainer.addChild(barClip);
			barClip.x = barX;
			barClip.y = _legendHeight-16;
			barClip.addEventListener(MouseEvent.CLICK,barClickHandler);
			barClip.addEventListener(MouseEvent.MOUSE_MOVE,barOverHandler);
			barClip.addEventListener(MouseEvent.ROLL_OUT,barOutHandler);			
			barClip.name = j.toString();
			
			var bar:Shape = new Shape();
			bar.graphics.beginFill(_inactiveColor,1);				
			bar.graphics.drawRect(0,0,barWidth,-barHeight);
			barClip.addChild(bar);
			bar.x = 0;
			bar.y = 0;
			bar.alpha = 0.5;
			
			var xAxisLabel:TextField = new TextField();			
			_xAxisLabels.addChild(xAxisLabel);
			xAxisLabel.x = barX;			
			xAxisLabel.width = barWidth;
			xAxisLabel.multiline = false;
			xAxisLabel.wordWrap = false;			
			xAxisLabel.text =  xLabel;
			xAxisLabel.autoSize = TextFieldAutoSize.CENTER;
			xAxisLabel.selectable = false;
			xAxisLabel.setTextFormat(_textFormat);
			if(j>1){
				var oldLabel:TextField = _xAxisLabels.getChildAt(_xAxisLabels.getChildIndex(xAxisLabel)-1) as TextField;			
				if(xAxisLabel.hitTestObject(oldLabel) && oldLabel.text != null && oldLabel.text != ''){
					_xAxisLabels.removeChild(xAxisLabel);
				}
			}
			
		}
		
		public function stepLegend(oldI:int,newI:int):void{
			
			changeBarColor(oldI,'inactive');
			changeBarColor(newI,'active');
			
		}
		
		public function barClickHandler(e:MouseEvent):void{
			
			var i:int = int(e.target.name)-1;
			_tempControls.stopTimer();
			var oldIndex = _tempControls.getAnimationIndex();
			changeBarColor(oldIndex,'inactive');
			_tempControls.setAnimationIndex(i);
			_tempControls.removePoints();
			_tempControls.attachPoints(i,_activeColor);			
			
		}
		
		public function barOverHandler(e:MouseEvent):void{
			
			_tempControls.stopTimer();
			var i:int = int(e.target.name)-1;
			changeBarColor(i,'highlight');
			_tempControls.attachPoints(i,_highlightColor);
			
			_toolTip.addToolTip("Frequency: " + _binArray[i].length.toString(),_textFormat,_stageWidth);
			
		}
		
		public function barOutHandler(e:MouseEvent):void{
			
			var i:int = int(e.target.name)-1;
			var animationIndex:int = _tempControls.getAnimationIndex();			
			if (i == animationIndex){				
				changeBarColor(i,'active');
			}else{
				changeBarColor(i,'inactive');
			}
			_tempControls.removePoints();
			_tempControls.attachPoints(_tempControls.getAnimationIndex(),_activeColor);
			
			_toolTip.removeToolTip();
						
		}
		
		public function changeBarColor(i:int,style:String){
			
			var theSprite:Sprite = _legendContainer.getChildAt(i) as Sprite;
			switch(style){
				case "inactive":
					theSprite.getChildAt(0).transform.colorTransform = _inactiveCT;
					theSprite.getChildAt(0).alpha=.5;
					break;
				case "active":
					theSprite.getChildAt(0).transform.colorTransform = _activeCT;				
					theSprite.getChildAt(0).alpha=1;
					break;
				case "highlight":
					theSprite.getChildAt(0).transform.colorTransform = _highlightCT;
					theSprite.getChildAt(0).alpha=1;
					break;
			}
			
		}
	}
}
		