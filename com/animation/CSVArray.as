package com.animation {
	
	import flash.net.URLLoader
	import flash.net.URLRequest
	
	import flash.events.Event
	
	public class CSVArray {
		
		private var _file:String;
		private var _isReady:Boolean;
		private var _dataArray:Array;
		private var _latHeader:String;
		private var _longHeader:String;
		
		public function CSVArray (inputFile:String,lat:String,long:String):void {
		
			_file=inputFile;
			_isReady=false;
			_dataArray = new Array();
			_latHeader=lat;
			_longHeader=long;
			
			loadData();
			
		}
		
		public function loadData ():void {
			
			var dataLoader:URLLoader = new URLLoader(new URLRequest(_file));
			dataLoader.addEventListener(Event.COMPLETE, processData); 
			
		}
		
		public function processData(e:Event):void {
	
			//a flag to determine if we are reading the header or if we are reading actual data	
			var pastHeader:Boolean = false;
			//split the CSV file into an array of all the rows
			var lines:Array = e.target.data.split("\r\n");	
				
			//loop through each row in the lines array to convert each row into an object
			for each (var line:String in lines) {
				//if not past the header, store this row as the header row
						
				if (!pastHeader) { 
					var headerRow:Array = line.split(',');
					pastHeader = true;
					continue;
				}
				//now split each line by the commas
				var attributes:Array = line.split(',');
				//create a dummy object to hold the value of each cell in the row
				//by using an object here, each row can be a different data type
				var lineObj:Object = new Object(); //this object will hold all the values for this row
				
				//loop through each cell in the row to store the values in the object
				for (var colNum:String in attributes) {
							
					if (isNaN(Number(attributes[colNum]))) {
						lineObj[headerRow[colNum]] = attributes[colNum];
					}else{
						if (Math.round(Number(attributes[colNum])) == Number(attributes[colNum])) {
							lineObj[headerRow[colNum]] = int(Number(attributes[colNum]));
						} else {
							lineObj[headerRow[colNum]] = Number(attributes[colNum]);
						}
					}
				}
				
				//now add the line object to the data array defined above
				_dataArray.push(lineObj);	
				trace(_dataArray[i].Latitude);
			}
	
			_dataArray = _dataArray.slice(0,_dataArray.length-1);
	
			makeReady();
	
		}
		
		public function makeReady ():void {
			_isReady=true;
		}
		
		public function getReady ():Boolean {
			return _isReady;
		}
		
		public function getDataArray ():Array {
			return _dataArray;
		}
		
		public function getLatHeader ():String {
			return _latHeader;
		}
		
		public function getLongHeader ():String {
			return _longHeader;
		}
		
	}
	
}
		