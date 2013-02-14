package com.animation {
	
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.display.Graphics;	
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.Timer;
	
	import fl.controls.ComboBox; 
	import fl.data.DataProvider;
	
	public class TemporalControls {

		private var _myMap:AnimatedMap;
		private var _temporalLegend:TemporalLegend;
		
		var _columnSelect:ComboBox = new ComboBox();
		
		private var _controls:Sprite;
		private var _play:Sprite;
		private var _pause:Sprite;
		private var _forward:Sprite;
		private var _back:Sprite;
		
		private var _animationTimer:Timer;
		private var _animationIndex:int;
		
		private var _inactiveColor:uint;
		private var _activeColor:uint;
		private var _highlightColor:uint;
		private var _inactiveCT:ColorTransform;
		private var _activeCT:ColorTransform;
		private var _highlightCT:ColorTransform;
		
		const BUTTON_FRAME_SIZE:Number = 25;
		const BUTTON_ICON_SIZE:Number = BUTTON_FRAME_SIZE/2;
		
		const BUTTON_STROKE_SIZE:int = 2;
		const BUTTON_STROKE_COLOR:uint = 0X000000;
		const BUTTON_STROKE_ALPHA:Number = 1;
		const BUTTON_FILL_COLOR:uint = 0X000000;
		const BUTTON_FILL_ALPHA:Number = .3;
		const BUTTON_Y:int = 35;
		const COLUMN_SELECT_X:int = 10;
		const COLUMN_SELECT_Y:int = 60;
		
		const RATE:int = 500;
		const REPEAT:int = 0;		
		
		public function TemporalControls (aMap:AnimatedMap) {
			
			_myMap=aMap;
			_animationIndex=0;
			_inactiveColor = _myMap.INACTIVE_COLOR;
			_activeColor = _myMap.ACTIVE_COLOR;
			_highlightColor = _myMap.HIGHLIGHT_COLOR;
			_inactiveCT = getCT('inactive');
			_activeCT = getCT('active');
			_highlightCT = getCT('highlight');									 
			
			//initialize the controls container
			_controls = new Sprite();
			_myMap.getMapStage().addChild(_controls);
			_controls.graphics.beginFill(_inactiveColor,0);
			_controls.graphics.drawRect(0,0,_myMap.getMapStage().stageWidth,_myMap.BOTTOM_HEIGHT);
			_controls.graphics.endFill();
			
			//intialize the select box for the data columns provided
			_controls.addChild(_columnSelect);
			_columnSelect.x = COLUMN_SELECT_X;
			_columnSelect.y = COLUMN_SELECT_Y;
			_columnSelect.dataProvider = new DataProvider(_myMap.getColumnsArray()); 
			_columnSelect.addEventListener(Event.CHANGE, columnSelectHandler);
			
			var play_x:Number = _columnSelect.width/2 + 10;
			var forward_x:Number = play_x+1.5*BUTTON_FRAME_SIZE;
			var back_x:Number = play_x-1.5*BUTTON_FRAME_SIZE;
			
			//initialize the play button
			_play = createButton();
			_controls.addChild(_play);
			_play.graphics.moveTo(-BUTTON_ICON_SIZE/4,-BUTTON_ICON_SIZE/2);
			_play.graphics.lineTo(-BUTTON_ICON_SIZE/4,BUTTON_ICON_SIZE/2);
			_play.graphics.lineTo(BUTTON_ICON_SIZE/2,0);
			_play.graphics.lineTo(-BUTTON_ICON_SIZE/4,-BUTTON_ICON_SIZE/2);
			_play.x=play_x;
			_play.addEventListener(MouseEvent.CLICK,playHandler);			
			
			//initialize the pause button
			_pause = createButton();
			_controls.addChild(_pause);
			_pause.graphics.beginFill(BUTTON_STROKE_COLOR,BUTTON_STROKE_ALPHA);
			_pause.graphics.drawRect(-BUTTON_ICON_SIZE/4,-BUTTON_ICON_SIZE/2,-BUTTON_ICON_SIZE/4,BUTTON_ICON_SIZE);
			_pause.graphics.drawRect(BUTTON_ICON_SIZE/4,-BUTTON_ICON_SIZE/2,BUTTON_ICON_SIZE/4,BUTTON_ICON_SIZE);
			_pause.x=play_x;
			_pause.addEventListener(MouseEvent.CLICK,pauseHandler);		
			_pause.visible=false;
			
			//initialize the forward button
			_forward = createButton();
			_controls.addChild(_forward);
			_forward.graphics.moveTo(-BUTTON_ICON_SIZE/4-1,-BUTTON_ICON_SIZE/2);
			_forward.graphics.lineTo(-BUTTON_ICON_SIZE/4-1,BUTTON_ICON_SIZE/2);
			_forward.graphics.lineTo(BUTTON_ICON_SIZE/2-2,0);
			_forward.graphics.lineTo(-BUTTON_ICON_SIZE/4-1,-BUTTON_ICON_SIZE/2);
			_forward.graphics.drawRect(BUTTON_ICON_SIZE/4+1,-BUTTON_ICON_SIZE/2,BUTTON_ICON_SIZE/6,BUTTON_ICON_SIZE);
			_forward.x=forward_x;
			_forward.addEventListener(MouseEvent.CLICK,forwardHandler);		
			
			//initialize the back button
			_back = createButton();
			_controls.addChild(_back);
			_back.graphics.moveTo(BUTTON_ICON_SIZE/4+1,BUTTON_ICON_SIZE/2);
			_back.graphics.lineTo(BUTTON_ICON_SIZE/4+1,-BUTTON_ICON_SIZE/2);
			_back.graphics.lineTo(-BUTTON_ICON_SIZE/2+2,0);
			_back.graphics.lineTo(BUTTON_ICON_SIZE/4+1,BUTTON_ICON_SIZE/2);
			_back.graphics.drawRect(-BUTTON_ICON_SIZE/4-4,-BUTTON_ICON_SIZE/2,BUTTON_ICON_SIZE/6,BUTTON_ICON_SIZE);
			_back.x=back_x;
			_back.addEventListener(MouseEvent.CLICK,backHandler);			
			
			_temporalLegend = new TemporalLegend(this,_controls,forward_x,_myMap.BOTTOM_HEIGHT);
			
		}
		
		public function createButton():Sprite{
			
			var button:Sprite = new Sprite();
			button.graphics.beginFill(BUTTON_FILL_COLOR,BUTTON_FILL_ALPHA);
			button.graphics.lineStyle(BUTTON_STROKE_SIZE,BUTTON_STROKE_COLOR,BUTTON_STROKE_ALPHA);
			button.graphics.drawCircle(0,0,BUTTON_FRAME_SIZE/2);
			button.graphics.endFill();
			button.graphics.beginFill(BUTTON_STROKE_COLOR,BUTTON_STROKE_ALPHA);
			button.y=BUTTON_Y;
			button.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			button.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
			
			return button;
			
		}
		
		public function setY(setY:int):void {
			
			_controls.y=setY;
			
		}
		
		public function drawLegend():void {
			
			var binArray:Array = _myMap.getCurrentBin().getBinArray();
			var labelArray:Array = _myMap.getCurrentBin().getLabelArray();
			var stageWidth:int = _myMap.getMapStage().stageWidth;
			_temporalLegend.drawHistogram(binArray,labelArray,stageWidth);
			
		}
		
		
		public function overHandler (e:MouseEvent) {
			
			e.target.alpha=.8;
		
		}
		
		public function outHandler (e:MouseEvent) {
			
			e.target.alpha=1;
		
		}
		
		public function playHandler (e:MouseEvent) {
			
			_play.visible=false;
			_pause.visible=true;
			
			_animationTimer = new Timer(RATE, REPEAT);
			_animationTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			_animationTimer.start();
		
		}
		
		public function pauseHandler (e:MouseEvent) {
			
			stopTimer();
		
		}
		
		
		function backHandler(event:MouseEvent):void{
			
			stopTimer();
			back();
			
		}
		
		function forwardHandler(eventevent:MouseEvent):void{
			
			stopTimer();
			step();
			
		}
				
		public function timerHandler(e:TimerEvent):void{
				
			step();
				
		}
		
		function stopTimer ():void{
			
			_play.visible=true;
			_pause.visible=false;
			
			if (_animationTimer!=null){
				_animationTimer.stop();
				_animationTimer=null;
			}
			
		}
		
		function step():void{
				
			var oldIndex:int = _animationIndex;
			//determine if the animation needs to be looped or not
			if (_animationIndex==_myMap.getCurrentBin().getBinArray().length-1){
				_animationIndex=0;
			}else{
				_animationIndex++;
			}
			removePoints();
			attachPoints(_animationIndex,_activeColor); 
			_temporalLegend.stepLegend(oldIndex,_animationIndex);
			
		}
		
		function back():void{
	
			var oldIndex:int = _animationIndex;
			//determine if the animation needs to be looped or not
			if (_animationIndex==0){
				_animationIndex=_myMap.getCurrentBin().getBinArray().length-1;				
			}else{
				_animationIndex--;
			}
			removePoints();
			attachPoints(_animationIndex,_activeColor); 
			_temporalLegend.stepLegend(oldIndex,_animationIndex);
			
		}
		
		function removePoints():void{
			
			_myMap.removePoints();
			
		}
		
		function attachPoints(index:int,color:uint):void{
			
			_myMap.attachPoints(index,color);
			
		}
		
		function columnSelectHandler(e:Event):void{
			
			_myMap.setCurrentBin(ComboBox(e.target).selectedIndex);
			
		}
		
		function getAnimationIndex():int{
			
			return _animationIndex;
			
		}
		
		function setAnimationIndex(i:int):void{
			
			_animationIndex = i;
			
		}
		
		public function getColor(type:String):uint{
			
			if(type=='inactive'){
				return _inactiveColor;
			}else if(type=='active'){
				return _activeColor;
			}else{
				return _highlightColor;
			}
			
		}
		
		public function getCT(type:String):ColorTransform{
			
			var ct:ColorTransform = new ColorTransform();
			if(type=='inactive'){
				ct.color=_inactiveColor;
			}else if(type=='active'){
				ct.color=_activeColor;
			}else{
				ct.color=_highlightColor;
			}
			return ct;
			
		}
		
	}	
}