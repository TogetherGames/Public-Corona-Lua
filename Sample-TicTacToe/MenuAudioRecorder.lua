--module(..., package.seeall)

local BaseState = require("BaseState");

local MenuAudioRecorder = {};
local super = BaseState;	--Inherit from BaseState
setmetatable(MenuAudioRecorder, { __index = super } );
local mt = { __index = MenuAudioRecorder };

-----------------
-- Constructor --
-----------------

function MenuAudioRecorder:New()
	local self = BaseState:New();
	setmetatable(self, mt);

   	self.type = BaseState.State_AudioRecorder;

	self.VoiceFile				= "";
	self.QueryTimer				= 0;
	
	self.StatusLabel			= nil;
	self.AudioRecorderStatus 	= "";

	self.AudioFilename 			= "";
	self.AudioRecorder 			= nil;
	self.AudioPlaybackHandle 	= nil;

	self.SampleRate8000Button	= nil;
	self.SampleRate11025Button	= nil;
	self.SampleRate16000Button	= nil;
	self.SampleRate22050Button	= nil;
	self.SampleRate44100Button	= nil;

	self.SampleRateButtonY		= 0;
	self.SampleRate 			= 44100;
-- Valid rates are 8000, 11025, 16000, 22050, 44100 but many devices do not
-- support all rates 

   	return self;
end

----------------------
-- Instance Methods --
----------------------

function MenuAudioRecorder:Enter()
	local TextButton = require("TextButton");
	local ImageButton = require("ImageButton");

	print("MenuAudioRecorder:Enter()");


	local displayGroup = self.displayGroup;

	local background = display.newRect(displayGroup, 0, 0, display.contentWidth, display.contentHeight);
	background:setFillColor(50, 50, 150);

    local backButton;
    local startRecordingButton = nil;
   	local stopRecordingButton = nil;
   	local playRecordingButton = nil;


    local function onBackButtonClicked()
   		ChangeState(BaseState.State_Main);
    end
    local function onStartRecordingButtonClicked()
   		self:StartRecording();
    end
    local function onStopRecordingButtonClicked()
   		self:StopRecording();
    end
    local function onPlayRecordingButtonClicked()
   		self:PlayRecording();
    end

	local function onSampleRate8000ButtonClicked()
		self:SetSampleRate(8000);
	end
	local function onSampleRate11025ButtonClicked()
		self:SetSampleRate(11025);
    end
    local function onSampleRate16000ButtonClicked()
    	self:SetSampleRate(16000);
    end
    local function onSampleRate22050ButtonClicked()
    	self:SetSampleRate(22050);
    end
    local function onSampleRate44100ButtonClicked()
    	self:SetSampleRate(44100);
    end
	
	
    
   	local topY = display.contentHeight * 0.1;

	local lineY = 240;
	local textFieldWidth = display.contentWidth - 200;


   	local title = display.newText(displayGroup, "Audio Recorder", 0, 0, native.systemFontBold, 42);
   	title.x = display.contentCenterX;
   	title.y = topY;

   	backButton = TextButton:New(displayGroup, "Back", onBackButtonClicked, 20);
   	 backButton:SetPos(80, 30);


   	self.StatusLabel = display.newText(displayGroup, "Stopped", 0, 0, native.systemFontBold, 36);
   	self.StatusLabel.x = display.contentCenterX;
   	self.StatusLabel.y = 220;

   	self.AudioFileSizeLabel = display.newText(displayGroup, "---", 0, 0, native.systemFontBold, 36);
   	self.AudioFileSizeLabel.x = display.contentCenterX;
   	self.AudioFileSizeLabel.y = 270;


	local buttonY = 400;
   	
    startRecordingButton = TextButton:New(displayGroup, "Start Recording", onStartRecordingButtonClicked, 20);
    startRecordingButton:SetPos(display.contentCenterX, buttonY);
	buttonY = buttonY + 60;

    stopRecordingButton = TextButton:New(displayGroup, "Stop Recording", onStopRecordingButtonClicked, 20);
    stopRecordingButton:SetPos(display.contentCenterX, buttonY);
	buttonY = buttonY + 60;

    playRecordingButton = TextButton:New(displayGroup, "Play Recording", onPlayRecordingButtonClicked, 20);
    playRecordingButton:SetPos(display.contentCenterX, buttonY);
	buttonY = buttonY + 60;

	buttonY = buttonY + 60;	
	self.SampleRateButtonY = buttonY;

-- Sample rate buttons.
	self.SampleRate8000Button = TextButton:New(displayGroup, "8000 hz", onSampleRate8000ButtonClicked, 20);
    self.SampleRate8000Button:SetPos(100, buttonY);
	buttonY = buttonY + 60;

	self.SampleRate11025Button = TextButton:New(displayGroup, "11025 hz", onSampleRate11025ButtonClicked, 20);
    self.SampleRate11025Button:SetPos(100, buttonY);
	buttonY = buttonY + 60;

	self.SampleRate16000Button = TextButton:New(displayGroup, "16000 hz", onSampleRate16000ButtonClicked, 20);
    self.SampleRate16000Button:SetPos(100, buttonY);
	buttonY = buttonY + 60;
	
	self.SampleRate22050Button = TextButton:New(displayGroup, "22050 hz", onSampleRate22050ButtonClicked, 20);
    self.SampleRate22050Button:SetPos(100, buttonY);
	buttonY = buttonY + 60;

	self.SampleRate44100Button = TextButton:New(displayGroup, "44100 hz", onSampleRate44100ButtonClicked, 20);
    self.SampleRate44100Button:SetPos(100, buttonY);
	buttonY = buttonY + 60;

-- Valid rates are 8000, 11025, 16000, 22050, 44100 but many devices do not
-- support all rates 




    unrequire("ImageButton");
    unrequire("TextButton");
    
    
    self:BuildAudioFile();
	self:CreateAudioRecorder();
	
	self:SynchSampleRateButtons();
end

function MenuAudioRecorder:Update(elapsedTime)
	
	-- Check for filename on the server to see if we need to download it.
	self.QueryTimer = self.QueryTimer - elapsedTime;
	
	if(self.QueryTimer < 0) then
		
		self.QueryTimer = 3;
		
		local function networkListener(event)
	   		print("VoiceChat - Local File: " .. self.VoiceFile);
	   		print("VoiceChat - Query Response: " .. event.response);
	   		
	   		if(event.response ~= self.VoiceFile) then
		   		self.VoiceFile = event.response;
		   		print("VoiceChat - Download new voice file.");
		   		self:DownloadRemoteVoice();
	   		end
	    end
		
	 	local params = {};
		params.body = "query=1";
		network.request("http://50.16.125.130:400/voicechat/voice.ashx", "POST", networkListener, params);
	end
end

function MenuAudioRecorder:DownloadRemoteVoice()

	local function networkListener(event)
		if(event.isError) then
			print("Network error - download of remote voice file failed");
		else
			self:PlayRemoteFile();
		end
	end
	
	network.download("http://50.16.125.130:400/voicechat/messages/" .. self.VoiceFile, "GET", networkListener, "remotefile.aif", system.TemporaryDirectory);
end

function MenuAudioRecorder:PlayRemoteFile()
	print("MenuAudioRecorder:PlayRemoteFile()");

	local function onPlaybackComplete(event)
		print("*** onPlaybackComplete()");
		audio.dispose(event.handle);
		self.AudioPlaybackHandle = nil;

		self.AudioRecorderStatus = "Stopped";
		self:SynchStatusLabel();	
	end

	if (self.AudioRecorder:isRecording()) then
	 	self.AudioRecorder:stopRecording();
	end

	if (self.AudioPlaybackHandle == nil) then
		print("Pre audio.loadStream(remotefile.aif)");
 		self.AudioPlaybackHandle = audio.loadStream("remotefile.aif", system.TemporaryDirectory);
	 	print("   self.AudioPlaybackHandle is not null");
	 	audio.play(self.AudioPlaybackHandle, { onComplete = onPlaybackComplete });
	 	
	 	self.AudioRecorderStatus = "Playing";
		self:SynchStatusLabel();
	end
end

function MenuAudioRecorder:SynchStatusLabel()
	self.StatusLabel.text = self.AudioRecorderStatus;
	
	if (self.AudioRecorderStatus == "Recording") then
		self.AudioFileSizeLabel.text = "---";
	else
		local audioFileSize = self:GetAudioFileSize();
		self.AudioFileSizeLabel.text = "" .. audioFileSize .. " bytes";
	end
end

function MenuAudioRecorder:SynchSampleRateButtons()
	local buttonY = self.SampleRateButtonY;

	if (self.SampleRate == 8000) then
		self.SampleRate8000Button:SetPos(300, buttonY);
	else
		self.SampleRate8000Button:SetPos(100, buttonY);
	end
	buttonY = buttonY + 60;


	if (self.SampleRate == 11025) then
		self.SampleRate11025Button:SetPos(300, buttonY);
	else
		self.SampleRate11025Button:SetPos(100, buttonY);
	end
	buttonY = buttonY + 60;


	if (self.SampleRate == 16000) then
		self.SampleRate16000Button:SetPos(300, buttonY);
	else
		self.SampleRate16000Button:SetPos(100, buttonY);
	end
	buttonY = buttonY + 60;


	if (self.SampleRate == 22050) then
		self.SampleRate22050Button:SetPos(300, buttonY);
	else
		self.SampleRate22050Button:SetPos(100, buttonY);
	end
	buttonY = buttonY + 60;


	if (self.SampleRate == 44100) then
		self.SampleRate44100Button:SetPos(300, buttonY);
	else
		self.SampleRate44100Button:SetPos(100, buttonY);
	end
	buttonY = buttonY + 60;
end	


------------------------------------------------
-- Events.
------------------------------------------------
function MenuAudioRecorder:StartRecording()
	print("MenuAudioRecorder:StartRecording()");
	if ("simulator" == system.getInfo("environment")) then
		showAlert("Uh On", "Recording is not supported in the Simulator.");
		return;
	end

	if (self.AudioRecorder:isRecording() == false) then
		self.AudioRecorder:setSampleRate(self.SampleRate);
		self.AudioRecorder:startRecording();

		self.AudioRecorderStatus = "Recording";
		self:SynchStatusLabel();
	end
end

function MenuAudioRecorder:StopRecording()
	print("MenuAudioRecorder:StopRecording()");

	-- Stop the recorder if it's currently recording.
	if (self.AudioRecorder:isRecording()) then
		self.AudioRecorder:stopRecording();
		
		self.AudioRecorderStatus = "Stopped";
		self:SynchStatusLabel();
		
		self:SendVoiceFile();
	end
end

function MenuAudioRecorder:PlayRecording()
	print("MenuAudioRecorder:PlayRecording()");

	local function onPlaybackComplete(event)
		print("*** onPlaybackComplete()");
		audio.dispose(event.handle);
		self.AudioPlaybackHandle = nil;

		self.AudioRecorderStatus = "Stopped";
		self:SynchStatusLabel();	
	end

	if (self.AudioRecorder:isRecording()) then
	 	self.AudioRecorder:stopRecording();
	end

	if (self.AudioPlaybackHandle == nil) then
		print("Pre audio.loadStream(" .. self.AudioFilename .. ")");
 		self.AudioPlaybackHandle = audio.loadStream(self.AudioFilename, system.DocumentsDirectory);
	 	print("   self.AudioPlaybackHandle is not null");
	 	audio.play(self.AudioPlaybackHandle, { onComplete = onPlaybackComplete });
	 	
	 	self.AudioRecorderStatus = "Playing";
		self:SynchStatusLabel();
	end
end

function MenuAudioRecorder:SendVoiceFile()
	local multipart = MultipartFormData:New();	--multipart:addHeader("Customer-Header", "Custom Header Value");	--multipart:addField("myFieldName","myFieldValue");	--multipart:addField("banana","yellow");
	
	local contentType = "audio/aiff";
	
	--[[
	local contentType = "audio/basic";
	local platformName = system.getInfo("platformName");
   	if ("iPhone OS" == platformName) then
       	contentType = "audio/aiff";
   	elseif ("Android" == platformName) then
       	contentType = "audio/pcm";
	--]]
		multipart:addFile("File", system.pathForFile( self.AudioFilename, system.DocumentsDirectory ), contentType, self.AudioFilename);		local params = {};	params.body = multipart:getBody(); -- Must call getBody() first!	params.headers = multipart:getHeaders(); -- Headers not valid until getBody() is called.		local function networkListener( event )		if ( event.isError ) then			print( "Network error!");		else			self.VoiceFile = event.response;		end	end		network.request("http://50.16.125.130:400/voicechat/voice.ashx", "POST", networkListener, params);
end

function MenuAudioRecorder:SetSampleRate(sampleRate)
	self.SampleRate = sampleRate;
	
	self:SynchSampleRateButtons();
end


function MenuAudioRecorder:BuildAudioFile()
	local audioFilename = "testfile";

	if ("simulator" == system.getInfo("environment")) then
    	audioFilename = audioFilename .. ".aif";
	else
        local platformName = system.getInfo("platformName");
    	if ("iPhone OS" == platformName) then
        	audioFilename = audioFilename .. ".aif";
    	elseif ("Android" == platformName) then
        	audioFilename = audioFilename .. ".pcm"
    	else
        	print("Unknown OS " .. platformName);
        end
    end
  
    self.AudioFilename = audioFilename;
	print("AudioFilename = " .. self.AudioFilename); 
end

function MenuAudioRecorder:CreateAudioRecorder()
	local filePath = system.pathForFile(self.AudioFilename, system.DocumentsDirectory);
	self.AudioRecorder = media.newRecording(filePath);
	if (self.AudioRecorder == nil) then
		print("   AudioRecorder not created.");
	else
		print("   AudioRecorder created successfully.");
		local sampleRate = self.AudioRecorder:getSampleRate();
		print("   SampleRate = " .. sampleRate);
	end
end

function MenuAudioRecorder:GetAudioFileSize()
	local fileSize = 0;
	local filePath = system.pathForFile(self.AudioFilename, system.DocumentsDirectory);
	local fileHandle = io.open(filePath, "r"); 
	if (fileHandle ~= nil) then
		fileSize = fileHandle:seek("end");
		io.close(fileHandle);
	end	
	return fileSize;
end       
            

return MenuAudioRecorder;



