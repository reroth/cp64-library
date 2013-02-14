package com.animation {
	
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;
	import com.google.maps.controls.*;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.styles.FillStyle;
	import com.google.maps.styles.StrokeStyle;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.InfoWindowOptions;
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import flash.events.Event;
	
	public class AnimatedMap {
		
		private var _mapKey:String;
		private var _longitude:Number;
		private var _latitude:Number;
		private var _scale:Number;
		private var _mapStage:Stage;
		
		private var _gmap:Map;
		private var _binArray:Array;
		private var _columnsArray:Array;
		private var _currentBin:Bin;
		private var _markersArray:Array;
		
		private var _tempControls:TemporalControls;
		
		const BOTTOM_HEIGHT:int = 100; 
		const MAP_X:int = 5;
		const MAP_Y:int = 5;
		const INACTIVE_COLOR:uint = 0x000000;
		const ACTIVE_COLOR:uint = 0x660000;
		const HIGHLIGHT_COLOR:uint = 0x00CCFF;
						
		public function AnimatedMap (key:String, lat:Number, long:Number, scl:Number, stage:Stage, bArray:Array, columns:Array) {
			
			_mapKey = key;
			_longitude = long;
			_latitude = lat;
			_scale = scl;
			_mapStage=stage;
			
			_markersArray = new Array();
			_columnsArray = columns;
			_binArray = bArray;
			_currentBin = _binArray[0];
		
			_gmap = new Map();
			//insert your API key into the quotations
			_gmap.key = _mapKey;
			_mapStage.addChild(_gmap);
			
			_tempControls = new TemporalControls (this);
			
			//initialize the stage layout
			initStage();			
						
			//add an event listener for the MAP_READY event
			//this listener calls the onMapReady function, which is used to add the markers
			_gmap.addEventListener(MapEvent.MAP_READY,onMapReady);	
			
		}
		
		public function getCurrentBin ():Bin {
			
			return _currentBin;
			
		}
		
		public function getColumnsArray():Array {
			
			return _columnsArray;
			
		}		
		
		public function getBinArray():Array {
			
			return _binArray;
			
		}		
		
		public function getMapStage():Stage {
			
			return _mapStage;
			
		}
		
		public function setCurrentBin (index:int):void {
			
			_currentBin = _binArray[index];
			removePoints();			
			attachPoints(0,ACTIVE_COLOR);
			_tempControls.drawLegend();
			
		}
		
		public function onMapReady(event:MapEvent):void {
			_gmap.setCenter(new LatLng(_latitude,_longitude), _scale);
			_gmap.addControl(new ZoomControl());
			_gmap.addControl(new ScaleControl());
			_gmap.addControl(new PositionControl());
			_gmap.addControl(new OverviewMapControl());
			_gmap.addControl(new MapTypeControl());
			attachPoints(0,ACTIVE_COLOR);
			_tempControls.drawLegend();
			
		}
		
		public function initStage():void {
			
			var stageBack:Sprite = new Sprite();
			stageBack.graphics.beginFill(INACTIVE_COLOR,.4);
			stageBack.graphics.drawRect(0,0,_mapStage.stageWidth,_mapStage.stageHeight);
			stageBack.name = "stageBG";
			_mapStage.addChildAt(stageBack,0);
			
			_mapStage.scaleMode = StageScaleMode.NO_SCALE;
			_mapStage.align = StageAlign.TOP_LEFT;

			updateMapSize();
			
			_mapStage.addEventListener(Event.RESIZE,resizeHandler);
			
		}
		
		public function resizeHandler(e:Event):void {
	
			updateMapSize()
	
		}
		
		public function updateMapSize():void {
			
			if (_gmap!=null){
				_gmap.setSize(new Point(_mapStage.stageWidth-2*MAP_X,_mapStage.stageHeight-BOTTOM_HEIGHT-2*MAP_Y));
			}
			_gmap.x=MAP_X;
			_gmap.y=MAP_X;
			
			_tempControls.setY(_mapStage.stageHeight-BOTTOM_HEIGHT);
			
			if (_tempControls!=null){
				_tempControls.drawLegend();
			}
			
			_mapStage.getChildByName("stageBG").width = _mapStage.stageWidth;
			_mapStage.getChildByName("stageBG").height = _mapStage.stageHeight;
		
		}
		
		//////////////////////////////////////////////////
		
		//function for determining which points to remove from the gmap
		public function removePoints():void {
			
			for (var i:int=0;i<_markersArray.length;i++) {
				
				_gmap.removeOverlay(_markersArray[i]);
				
			}
		
		}
		
		//function for determining which points to attach to the gmap
		public function attachPoints(binIndex:int, color:uint):void {
						
			//loop through all rows in the dummyArray to check each crime
			for (var i:int=0;i<_currentBin.getBinArray()[binIndex].length;i++) {
				
				//trace(dummyArray[i]);
				attachMarker(_currentBin.getBinArray()[binIndex][i], color);
				
			}
			
		}
		
		//function to actually attach a single marker of ID i to the gmap
		public function attachMarker(i:int, color:uint):void{
			
			//set the appropriate row from which to draw data for this specific marker instance
			var row:Object = _currentBin.getCSVArray().getDataArray()[i];	
			var markerDummy:Marker = new Marker(
				new LatLng(row[_currentBin.getCSVArray().getLatHeader()], row[_currentBin.getCSVArray().getLongHeader()]),
				new MarkerOptions({
						  icon: getSmallCircle(i, color),
						  hasShadow: false
				})
			);
			markerDummy.addEventListener(MapMouseEvent.ROLL_OVER,overHandler);
			_gmap.addOverlay(markerDummy);
			_markersArray.push(markerDummy);
			
		}
		
		//draws a small circle in the marker
		public function getSmallCircle(i:int, color:uint):Shape {
			var circle:Shape = new Shape();
			var circleAlpha:Number;
			if (color==ACTIVE_COLOR){
				circleAlpha = .8;
			}else{
				circleAlpha = .65;
			}
			circle.graphics.beginFill(color,circleAlpha);
			circle.graphics.lineStyle(1,0x000000,.9);
			circle.graphics.drawCircle(0,0,7);
			circle.name=i.toString();
			return circle;
		}
		
		//draws a large circle in the marker
		public function getBigCircle(i:int):Shape {
			var circle:Shape = new Shape();
			circle.graphics.beginFill(ACTIVE_COLOR,1);
			circle.graphics.lineStyle(1,0x000000,.9);
			circle.graphics.drawCircle(0,0,10);
			circle.name=i.toString();
			return circle;
		}
		
		//handler for mouse-over events for the markers
		function overHandler(e:MapMouseEvent):void {
			//extract the ID of the current marker by finding the icon name
			var i:int = int(e.target.getOptions().icon.name); 
			//replace the small circle with a large circle for positive feedback
			var options:MarkerOptions = new MarkerOptions({icon: getBigCircle(i)});
			e.target.setOptions(options);
			
			//update event listeners
			e.target.removeEventListener(MapMouseEvent.ROLL_OVER,overHandler);
			e.target.addEventListener(MapMouseEvent.ROLL_OUT,outHandler);
			e.target.addEventListener(MapMouseEvent.CLICK,clickHandler);
		}
		
		//handler for mouse-out events for the markers
		function outHandler(e:MapMouseEvent):void {
			//extract the ID of the current marker by finding the icon name
			var i:int = int(e.target.getOptions().icon.name);
			//replace the large circle with a small circle for positive feedback
			var black:uint = ACTIVE_COLOR;
			var options:MarkerOptions = new MarkerOptions({icon: getSmallCircle(i, black)});
			e.target.setOptions(options);
			
			//update event listeners
			e.target.removeEventListener(MapMouseEvent.ROLL_OUT,outHandler);
			e.target.removeEventListener(MapMouseEvent.CLICK,clickHandler);
			e.target.addEventListener(MapMouseEvent.ROLL_OVER,overHandler);
		}
		
		//handler for click events for the markers
		function clickHandler(e:MapMouseEvent):void {
			
			_tempControls.stopTimer();
			
			//update event listeners
			e.target.removeEventListener(MapMouseEvent.CLICK,clickHandler);
			e.target.addEventListener(MapMouseEvent.ROLL_OUT,outHandler);
			
			//extract the ID of the current marker by finding the icon name
			var i = int(e.target.getOptions().icon.name);
			
			//populate the pop-up info window with the CSV data
			var newOptions:InfoWindowOptions = new InfoWindowOptions();			
			var row:Object = _currentBin.getCSVArray().getDataArray()[i];
			newOptions.contentHTML = "";
			for (var item in row) {
				newOptions.contentHTML += "<b>" + item + ":  </b>" + row[item] + "\r";
			}
			
			//adjust the width and position of the info window to match the marker icon
			newOptions.pointOffset=new flash.geom.Point(-1,0);
			newOptions.width=210;
			
			//open the info window
			e.target.openInfoWindow(newOptions);
			
		}			
	}
}