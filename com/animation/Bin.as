package com.animation {
		
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import flash.events.TimerEvent;
	
	public class Bin {
		
		private var _myCSVArray:CSVArray;
		private var _column:String;
		private var _labelColumn:String;
		private var _loadTimer:Timer;
		private var _binArray:Array;
		private var _xLabelArray:Array;
		
		public function Bin (csv:CSVArray,col:String,lCol:String):void {	
		
			_myCSVArray = csv;
			_column = col;
			_labelColumn = lCol;
			_binArray = new Array();
			_xLabelArray = new Array();
		
			if (!_myCSVArray.getReady()){
				_loadTimer = new Timer (100,0);
				_loadTimer.addEventListener(TimerEvent.TIMER,loadTimerHandler);
				_loadTimer.start();
			} else {
				binData();
			}
		}
		
		public function loadTimerHandler (e:TimerEvent):void {
			if(_myCSVArray.getReady()){
				_loadTimer.stop();
				_loadTimer.removeEventListener(TimerEvent.TIMER,loadTimerHandler);
				binData()
			}
		}
		
		function binData():void {
	
			var dummyArray:Array = cloneArray(_myCSVArray.getDataArray());
			dummyArray.sortOn(_column, Array.NUMERIC);
						
			var min:int = dummyArray[0][_column];
			var max:int = dummyArray[dummyArray.length-1][_column];
			
			var indexArray:Array = new Array();
			var xLabel:String;
			
			for (var currentBin:int=min; currentBin<=max; currentBin++){
				
				xLabel = '';
								
				for (var i:int=0; i<_myCSVArray.getDataArray().length; i++){
					
					if (_myCSVArray.getDataArray()[i][_column]==currentBin){
						
						indexArray.push(i);
						xLabel = _myCSVArray.getDataArray()[i][_labelColumn]

					}
					
				}
				
				_xLabelArray.push(xLabel);
				
				_binArray.push(indexArray);
				indexArray = new Array ();
				
			}
			
		}
		
		function cloneArray(source:Object):* {
		    var myBA:ByteArray = new ByteArray();
		    myBA.writeObject(source);
		    myBA.position = 0;
		    return(myBA.readObject());
		}
		
		public function getBinArray ():Array {
			return _binArray;
		}
		
		public function getLabelArray ():Array {
			return _xLabelArray;
		}
		
		public function getCSVArray ():CSVArray {
			return _myCSVArray;
		}
		
	}
		
}
		