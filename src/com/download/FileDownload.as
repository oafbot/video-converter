package com.download {
    import flash.events.*;
    import flash.net.*;
    
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.ProgressBar;
    import mx.core.UIComponent;
    import mx.events.CloseEvent; 
    
    public class FileDownload extends UIComponent {

        public  var DOWNLOAD_URL:String;
        private var SCRIPT_URL:String;
        private var fr:FileReference;
        // Define reference to the download ProgressBar component.
        private var pb:ProgressBar;
        // Define reference to the "Cancel" button which will immediately stop the download in progress.
        private var btn:Button;
		private var fileNames:Array;
		private var loader:URLLoader;
		private var request:URLRequest;
		//private var deleteFiles:String = null;
		//private var downloadFiles:String = null;
		private var fileString:String = null;
		private var format:String;
		private var guid:String;
		
        public function FileDownload() {

        }

        /**
         * Set references to the components, and add listeners for the OPEN,
         * PROGRESS, and COMPLETE events.
         */
        public function init(pb:ProgressBar, btn:Button, dURL:String, sURL:String, fileNames:Array, conversionFormat:String, uniqueId:String ):void {
            // Set up the references to the progress bar and cancel button, which are passed from the calling script.
            this.pb = pb;
            this.btn = btn;
			this.fileNames = fileNames;
			this.format = conversionFormat;
			this.guid = uniqueId;
			this.fileString = getFileString();
			
			pb.indeterminate=false;
			pb.mode = "manual";
			
			
			SCRIPT_URL = sURL;			
            DOWNLOAD_URL = dURL;

            fr = new FileReference();
            fr.addEventListener(Event.OPEN, openHandler);
            fr.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            fr.addEventListener(Event.COMPLETE, completeHandler);
        }

        /**
         * Immediately cancel the download in progress and disable the cancel button.
         */
        public function cancelDownload():void {
            fr.cancel();
            pb.label = "DOWNLOAD CANCELLED";
            btn.enabled = false;
            deleteTemp();
        }

        /**
         * Begin downloading the file specified in the DOWNLOAD_URL constant.
         */
        public function startDownload():void {
            
            this.parentDocument.fileUpload.resetEncodeData();
            
            var request:URLRequest = new URLRequest();
            request.url = SCRIPT_URL;
            
            var requestVars:URLVariables = new URLVariables();
			
			requestVars.action = "download";
			//requestVars.files = getfileString();
			requestVars.files = fileString;
			requestVars.format = this.format;
			requestVars.guid = guid;
			request.data = requestVars;           
            
            loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, requestComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);
			          
        }
				
		private function downloadZip():void{
 
            var request:URLRequest = new URLRequest();
            request.url = DOWNLOAD_URL+guid+"/"+"converted_files.zip";          
                                
            fr.download(request);			
		}
		
				
        /**
         * When the OPEN event has dispatched, change the progress bar's label
         * and enable the "Cancel" button, which allows the user to abort the
         * download operation.
         */
        private function openHandler(event:Event):void {
            pb.label = "DOWNLOADING %3%%";
            btn.enabled = true;
            btn.enabled = false;
            //pb.visible = true;
        }

        /**
         * While the file is downloading, update the progress bar's status and label.
         */
        private function progressHandler(event:ProgressEvent):void {
            pb.setProgress(event.bytesLoaded, event.bytesTotal);
        }

        /**
         * Once the download has completed, change the progress bar's label and
         * disable the "Cancel" button since the download is already completed.
         */
        private function completeHandler(event:Event):void {
            pb.label = "DOWNLOAD COMPLETE";
            pb.indeterminate = false;
            pb.setProgress(0, 100);
            //btn.enabled = false;
            btn.enabled = true;
            //pb.visible = false;
            deleteTemp();
        }

        private function deleteTemp():void{
        			
			request = new URLRequest();
        	//request = new URLRequest("http://140.247.196.16/video/download.php?delete="+fileNames);
			request.method = URLRequestMethod.GET;
			request.url = SCRIPT_URL;

			var requestVars:URLVariables = new URLVariables();
			
			requestVars.action = "delete";
			//requestVars.files = getfileString();
			requestVars.files = fileString;
			requestVars.format = this.format;
			//requestVars.zip = guid;
			requestVars.guid = guid;
			request.data = requestVars;
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, requestComplete);
			//loader.addEventListener("httpStatus", onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.load(request);
        }
    	
    	private function requestComplete(evt:Event):void {
			var responseTxt:String = evt.target.data;
			trace( responseTxt);
			
			if (responseTxt == "deleted"){
				loader.close();
				trace("deleted");
				destruct();
			}
			else if(responseTxt.substring(responseTxt.length-6) == "ZIPPED"){
				
				Alert.show("Click OK to Download.", "File Conversion Complete:", 03, this, closeAlert);
			}			
			else{
				loader.close();
				destruct();
			}
		}       
		
      	public function closeAlert(event:CloseEvent):void{
        	if(event.detail == Alert.YES){
				downloadZip();
				trace('downloading zipfile');
      		}
        	else{      
        		deleteTemp();
        		destruct();
        	}
        }
        
		private function onIOError(event:IOErrorEvent):void {  
			trace("Error loading URL.");
			destruct();
		}
		
		public function getFileString():String{
			
			for( var i:uint=0; i<fileNames.length; i++ ){
				if ( i == 0 ){
					fileString = fileNames[i].name;
				}
				else{
					fileString = fileString + "+" + fileNames[i].name;
				}
			}
			return fileString; 
		}
		
		private function destruct():void{
				format = null;
				fileString = null;
				guid = null;			
		}
		  
    }	//class
}	//package
