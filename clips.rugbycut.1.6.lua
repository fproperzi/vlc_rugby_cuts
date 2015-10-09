--[[ "rugbycut.lua"
    Extension Information:
        Name: Rugby Cuts
        Version: 1.6
        Author: Kino
        Website: http://rugby.it
        Description: A small rugby clip cutter for your VLC Player. 
]]--

--[[
    INSTALLATION:
    Put the file in the VLC subdir /lua/extensions, by default:
    * Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
    * Windows (current user): %APPDATA%\VLC\lua\extensions\
    next version also:
    * Linux (all users): /usr/share/vlc/lua/extensions/
    * Linux (current user): ~/.local/share/vlc/lua/extensions/
    * Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
    (create directories if they don't exist)
    Restart the VLC.
    USAGE:
    Load Video in your Playlist and start to play.
    Then you simply use the extension by going to the "View" menu and selecting it there.
    These tool work good if you load in VLC one video at time, is not suited to cut a clip cross 2 videos in VLC playlist!
    My personal opinion is to give name at video like: 
    
        "20150901 tre mun.xxx"  (xxx is the extension for video file,avi,mov,mpg,mp4...)
        
    if you have 2 video one per half:
    
       first half: "20150901A tre mun.xxx"
      second half: "20150901B tre mun.xxx"
      
    if you have video from different angles :
    
       side angle: "20150901-SIDE tre mun.xxx"
       back angle: "20150901-BACK tre mun.xxx" 
       
    cut one then reopen and load VLC and cut the other
    (option to reuse cuts from SIDE to BACK in progress)
     
    And then the clips will be (single 80 min video): 
    
        tre koA5L-.20150901 tre mun.001.mp4
        mun l5A2L+d@.20150901 tre mun.002.mp4
        
    every name clip has information about 
    
          who: mun      -> team
         what: l5       -> start play (lineout 5 men)
        where: A2L      -> attack 22 mt Left (see the field hre below)
          how: +d@      -> win (+) & drive (d), try (@)
         date: 20150901 -> year (2015) month (09) day (01)
        match: tre mun  -> home team (tre, treviso), away team (mun, munster)
         when: 002      -> progressive clip number (the second clip in the match)
         
    Remember: when you cut, start few second before the real start of the action 
              and finish few second after the real end.
              Get the refeere signal help!!

    AAA
    neeed to set directory for prgm cutter
    ex.:
    gsHandBrake = "c:/Programs/Handbrake/HandBrakeCLI.exe"
    gsFFmpeg    = "c:/Programs/ffmpeg/ffmpeg.exe"
    gsBaseDir   = "c:/"

--]]

--[[
    
    Copyright © 2013 Franco Properzi (kino)
     
     Authors:  Franco Properzi (Kino)
     Contact: fproperzi at gmail.com
     
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.
     
     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.
     
     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
]]--

--[[
    ridefinire i tasti per vlc
	q - salto corto indietro
	w - salto corto in avanti
	a - aumenta velocita
	z - velocita normale
	salto corto ad 1 secondo
]]--
gsVersion   = "v1.6"
gsTitle     = "Rugby Cuts "..gsVersion.." @base file ed."
gsHandBrake = "c:/HandBrakeCLI.exe"
gsFFmpeg    = "c:/ffmpeg.exe"
gsBaseDir   = "c:/"     -- base directory for all stuff: db with cuts, batch files, cuts
gsVideo     = ""        -- video opened
gsUri       = ""        -- uri file
gsBaseFile  = ""        -- video without extension
gsTimeShift = ""        -- video time shift from tag
gsDBFile    = ""        -- db file, base.txt
d = {}
gaas = {}
gaasLst = {}
gs={T1="",T2="",who="",zona="",what="",result="",note="",try="",start=0}

gasWho = {""            -- insert/change here teams, PLEASE 3 letters to identify a team
,"----------------RAB"	
,"car"	-- Cardiff Blues
,"con"	-- Connacht
,"dra"	-- Newport Gwent Dragons
,"edi"	-- Edinburgh
,"gla"	-- Glasgow Warriors
,"lnr"	-- Leinster
,"mun"	-- Munster 
,"osp"	-- Ospreys
,"sca"	-- Scarlets 
,"tre"	-- Benetton Treviso
,"uls"	-- Ulster
,"zeb"	-- Zebre
,"----------------S10"	
,"cal"	-- calvisano
,"ffo"	-- fiamme oro
,"laz"	-- lazio
,"mgl"	-- mogliano
,"pad"	-- padova
,"pia"	-- piacenza
,"laq"	-- laquila
,"rom"	-- roma
,"rov"	-- rovigo
,"snd"	-- san dona
,"via"	-- viadana
,"vs_"	-- vs
,"----------------FRA"	
,"bay"	-- Bayonne
,"bdx"	-- Bordeaux Begles
,"bia"	-- Biarritz 
,"bri"	-- Brive 
,"cas"	-- Castres
,"cle"  -- Clermont Auvergne
,"gre"	-- Grenoble 
,"mon"	-- Montpellier 
,"oyo"	-- Oyonnax 
,"per"	-- Perpignan	
,"rac"	-- Racing Metro
,"sta"	-- Stade Francais
,"tln"	-- Toulon
,"tou"	-- Toulouse
,"----------------ENG"	
,"bat"  -- bath
,"exe"  -- Exeter
,"glo"  -- Gloucester 
,"har"	-- Harlequins
,"lei"	-- Leicester 
,"lir"  -- london irish
,"ncl"	-- Newcastle
,"ntn"	-- Northampton
,"sal"	-- Sale
,"sar"	-- Saracens 
,"wos"  -- worcester
,"wsp"  -- London Wasps
,"----------------Cup Qualifiers"	
,"cdu"  -- CDU Lisbona
,"eni"  -- Enisey CRM
,"kry"  -- krasniy Yar
,"----------------International"	
,"arg"  -- Argentina
,"aus"	-- Australia
,"eng"	-- Inghilterra
,"fra"  -- Francia
,"ire"	-- Irlanda
,"ita"	-- Italia
,"nzl"	-- New Zeland
,"saf"	-- Sud Africa
,"sco"	-- Scozia
,"wal"	-- Galles
,
}
gasWhat = {""   -- add or change what you want but PLEASE use 2 letters/chars
,"ko"	        -- kick off
,"s8"	        -- scrum, 8 run/feed
,"s9"	        -- scrum, 9 run/feed 
,"22"	        -- restart 22 mt
,"cp"	        -- penalty kick / free kick: use yhis for place kick to post, quick tap, kick to lineout after penalty 
,"l7"	        -- lineout 7 men
,"l6"	        -- lineout 6 men
,"l5"       
,"l4"       
,"l3"       
,"l2"       
,"ln"           -- lineout 7+, more then 7 men
,"lq"	        -- lineout quick
,"cn"	        -- conversion
,"rp"	        -- replay (do you want a clip width replay
}
 
--
--              Attack direction -->                                 Attack direction -->
--      ------------------------------------                ------------------------------------ 
--      |        |        |        |       |                |        |        |        |       |    
--      |  D2O   |  D5O   |  A5O   |  A2O  |     Ovest      |  D2L   |  D5L   |  A5L   |  A2L  |    Left     
--      |        |        |        |       |                |        |        |        |       |          
--    __|        |        |        |       |__            __|        |        |        |       |__        
--      |  D2N   |  D5N   |  A5N   |  A2N  |     Nord       |  D2C   |  D5C   |  A5C   |  A2C  |    Center
--    __|        |        |        |       |__            __|        |        |        |       |__        
--      |        |        |        |       |                |        |        |        |       |          
--      |  D2E   |  D5E   |  A5E   |  A2E  |     Est        |  D2R   |  D5R   |  A5R   |  A2R  |    Right  
--      |        |        |        |       |                |        |        |        |       |          
--      ------------------------------------                ------------------------------------
--         0-22    22-50    50-22    22-0                       0-22    22-50    50-22    22-0
--
--
--
--        22                                          KO                                    A/D                  old 22            
--                                                   ___________|____|___________            ___|__|___	          ___|__|___		
--      | |   |       4        |   | |              | |   |                |   | |          |          |         |          |  
--      |-|4 -|- - - - - - - - |- 4|-|              | |4  |       4        |  4| |          |   Att    |         |__________|  
--   50 |_|___|________________|___|_| 50        22 |_|___|________________|___|_| 22       |          |         |     2    |  
--      | |  3|       3        |3  | |              | |3  |       3        |  3| |        50|__________|50     50|__________|50
--   40 |-|- -|- - - - - - - - |- -|-| 40           | |2  |1      1       1|  2| |          |          |         |     1    |  
--      | |2  |1      1       1|  2| |              |-|- -|- - - - - - - - |- -|-|          |   Def    |       22|__________|22
--   22 |_|___|________________|___|_| 22           | | O |       N        | E | |          |          |         | O  N   E |  
--      |   O |       N        | E   |           50 |_|___|________________|___|_| 50     0 |__________| 0       |__________|  
--	

gasZona   = {""                                   
,"D2L" -- sx Ovest Left 
,"D5L"
,"A5L"
,"A2L"
,"D2C" -- cx Nord Center
,"D5C"
,"A5C"
,"A2C"
,"D2R" -- dx Est Right 
,"D5R"
,"A5R"
,"A2R"
}		                 
gasResult = {""
,"+"	-- win 
,"+d"	-- win & drive (lineout)
,"++"	-- win per penalty,free kick
,"~"	-- win bad
,"-"	-- lost
,"--"	-- lost per penalty,free kick
,"r"	-- reset (scrum)
,"+!"	-- furba
}
gasTry    = {"","@"}

--[[
    VLC-Event Functions
]]--

function descriptor()
	return {
		   title = gsTitle;
		 version = gsVersion;
		  author = "Kino";
			 url = 'http://addons.videolan.org/content/show.php?content=';
	   shortdesc = "Controls for rugby cut."..gsVersion;
	 description = "Cut rugby clips.";
	capabilities = {"input-listener"}
    }
end
function activate()
    vfLog(gsTitle)
	
	if vlc.input.item() == nil then 
		local w = vlc.dialog("Alert")
		w:add_label("Nessun video selezionato"	, 1, 2, 1, 1)
		w:add_button("OK",deactivate , 1, 4, 2, 2)
		w:show()
		return
	end
	gsVideo    = vlc.input.item():name()
    gsDBFile   = gsBaseDir..gsVideo..".txt"
	gsUri      = string.gsub(vlc.input.item():uri(), "file:///","")
    gsBaseFile = string.sub( vlc.input.item():name() ,1 , -5)  
	--gsTimeShift = ""
    --copy old db file (if exist) in variables
	pcall(dofile,gsDBFile)
    vfCreateMainDialog()
	
	--dofile(gsDBFile)
	
	vfSetLst()
	-- local str=" "
	-- for k,v in pairs(gaas) do 
	-- 	str = str..","..k.."="..v.start 
	-- end
	-- vfLog(str)
	-- add_callback not in VLC 2.2.1
	--vlc.var.add_callback( vlc.object.libvlc(), "key-pressed", key_press )
end
function deactivate()
	-- add_callback not in VLC 2.2.1
	--vlc.var.del_callback( vlc.object.libvlc(), "key-pressed", key_press )
    vfCloseMC()
end
function close()
    vfCloseMC()
end
function input_changed()
    vfLog("Input changed", 3)
    vfUpdateNowPlaying()
end
function meta_changed()
    --stub
end
function playing_changed()
    --stub
end
-- add_callback not in VLC 2.2.1
-- vlc.var.del_callback( vlc.object.libvlc(), "key-pressed", key_press )
--
function key_press( var, old, new, data )
	if new==65 then vlc.var.set(vlc.object.input(), "rate", (vlc.var.get(vlc.object.input(), "rate") ==1 and 5 or 1) ) end
	if new==32 and vlc.input.is_playing() then vlc.playlist.pause() end
	if new==32 and not (vlc.input.is_playing()) then vlc.playlist.play() end
	if new==113 then  vlc.var.set(input,"position",vlc.var.get(input,"position") - 1) end
	if new==118 then  vlc.var.set(input,"position",vlc.var.get(input,"position") + 1) end 
end

function vfCloseMC()
    vfLog("Stopping "..gsTitle)
    --d.mainDialog:delete()
    vlc.deactivate()
end

function play()
    vlc.playlist.play()
    d.mainDialog:del_widget(d.button_playPause)
    d.button_playPause = d.mainDialog:add_button("Pause", pause, 1, 3)
end

function pause()
    vlc.playlist.pause()
    d.mainDialog:del_widget(d.button_playPause)
    d.button_playPause = d.mainDialog:add_button("Play", play, 1, 3)
end

function stop()
    vlc.playlist.stop()
    d.mainDialog:del_widget(d.button_playPause)
    d.button_playPause = d.mainDialog:add_button("Play", play, 1, 3)
end

function nextItem()
    vlc.playlist.next()
end

function previousItem()
    vlc.playlist.prev()
end

function vfUpdateNowPlaying()
    d.label_nowPlaying:set_text("Now Playing: "..vlc.input.item():name())
    d.mainDialog:set_title(gsTitle.." - "..vlc.input.item():name())
end
-----------------------------------------



-- main dialog
--
function vfCreateMainDialog()
    
    d.mainDialog = vlc.dialog(gsTitle.." - "..vlc.input.item():name())
    local dialog = d.mainDialog

	d.ddTeam1 = dialog:add_dropdown(1, 1, 2, 1)
	d.ddTeam2 = dialog:add_dropdown(3, 1, 2, 1)
	for k,v in pairs(gasWho) do
        d.ddTeam1:add_value(v, k)
		d.ddTeam2:add_value(v, k)
    end
                                                -- col ,row ,width ,height
	d.btnT1	= dialog:add_button("^^^",vfBtnWho1 	    ,1, 2, 2, 2)
	d.btnT2	= dialog:add_button("^^^",vfBtnWho2 	    ,3, 2, 2, 2)
        
    d.lbl1 = dialog:add_label("What / Result:"	        ,1, 4, 1, 1)                                                       
	d.ddWhat   = dialog:add_dropdown(                    2, 4, 1, 1)
    d.ddResult = dialog:add_dropdown(                    3, 4, 1, 1)
	d.chkTry   = dialog:add_check_box("@ Try",false     ,4, 4      )
    
    d.lblWhere = dialog:add_label("Where:"	            ,1, 5, 1, 1)
    d.lblWho   = dialog:add_label("Who:"	            ,2, 5, 1, 1)
    d.lblWhen  = dialog:add_label("When:"               ,3, 5, 2, 1)

    
	--d.lblWho   = dialog:add_label("Who:"	        ,1, 4, 1, 1)
	--d.lblWhen  = dialog:add_label("When:"	        ,2, 4, 1, 1)
	--d.lblWhere = dialog:add_label("Where:"	    ,3, 4, 1, 1)
    --d.lblWhat  = dialog:add_label("What:"	        ,4, 4, 1, 1)
	
	d.a1 = dialog:add_button("D2L"		,vfBtnWhereA1	,1, 6, 1, 1)
	d.a2 = dialog:add_button("D5L"		,vfBtnWhereA2   ,2, 6, 1, 1)
	d.a3 = dialog:add_button("A5L"		,vfBtnWhereA3	,3, 6, 1, 1)
	d.a4 = dialog:add_button("A2L"		,vfBtnWhereA4	,4, 6, 1, 1)
    
	d.b1 = dialog:add_button("D2C"		,vfBtnWhereB1	,1, 7, 1, 1)
	d.b2 = dialog:add_button("D5C"		,vfBtnWhereB2   ,2, 7, 1, 1)
	d.b3 = dialog:add_button("A5C"		,vfBtnWhereB3	,3, 7, 1, 1)
	d.b4 = dialog:add_button("A2C"		,vfBtnWhereB4	,4, 7, 1, 1)
    
	d.c1 = dialog:add_button("D2R"		,vfBtnWhereC1	,1, 8, 1, 1)
	d.c2 = dialog:add_button("D5R"		,vfBtnWhereC2   ,2, 8, 1, 1)
	d.c3 = dialog:add_button("A5R"		,vfBtnWhereC3	,3, 8, 1, 1)
	d.c4 = dialog:add_button("A2R"		,vfBtnWhereC4	,4, 8, 1, 1)


    
   
	
	for k,v in pairs(gasWhat) do
		d.ddWhat:add_value(v, k)
	end
	for k,v in pairs(gasResult) do
		d.ddResult:add_value(v, k)
	end
    d.lbl4 = dialog:add_label("Note:"	                ,1,10, 1, 1)
    d.txtNote 	= dialog:add_text_input (""             ,2,10, 3, 1)
    --d.log = dialog:add_label("", 1, 8, 2, 1)
	
    d.btnAddCut = dialog:add_button("End of Play", vfBtnAddCut, 1, 11, 4, 1)
    
	
	d.lstCuts = dialog:add_list(1, 12, 4, 1)
	--d.lstCuts2 = dialog:add_list(1, 15, 4, 1)

    --vfUpdateNowPlaying()
	d.btnDoGo   = dialog:add_button("Go"		,vfBtnGoClip	,1, 13, 1, 1)
	d.btnDoGoE  = dialog:add_button("Go end"	,vfBtnGoClipEnd ,2, 13, 1, 1)
	d.btnDoDel  = dialog:add_button("Del"		,vfBtnDelClip	,3, 13, 1, 1)
	d.btnInfo   = dialog:add_button("info"		,vfBtnClipInfo  ,4, 13, 1, 1)
    
    d.lbl5      = dialog:add_label("Base file:"                 ,1, 14, 1, 1)
    d.txtBFile 	= dialog:add_text_input (gsBaseFile             ,2, 14, 2, 1)
    
    d.lbl6      = dialog:add_label("Shift:"                     ,1, 15, 1, 1)
    d.txtTShift	= dialog:add_text_input (gsTimeShift            ,2, 15, 2, 1)
	--d.btnBfile  = dialog:add_button("Save"	    ,vfBtnMp4Cut	,4, 14, 1, 1)
	
	d.btn1 = dialog:add_button("VReDo"			,vfBtnVideoRedo	,1, 16, 1, 1)
	d.btn2 = dialog:add_button("m3u"			,vfBtnM3u		,2, 16, 1, 1)
	d.btn3 = dialog:add_button("Just Cut"		,vfBtnJCut		,3, 16, 1, 1)
	d.btn4 = dialog:add_button("Mp4 Cut"	    ,vfBtnMp4Cut	,4, 16, 1, 1)

	dialog:update()
    dialog:show()
    
end

function vfBtnWhereA1()	gs.zona = d.a1:get_text();vf4WH()	end
function vfBtnWhereA2()	gs.zona = d.a2:get_text();vf4WH()	end
function vfBtnWhereA3()	gs.zona = d.a3:get_text();vf4WH()	end
function vfBtnWhereA4()	gs.zona = d.a4:get_text();vf4WH()	end

function vfBtnWhereB1()	gs.zona = d.b1:get_text();vf4WH()	end
function vfBtnWhereB2()	gs.zona = d.b2:get_text();vf4WH()	end
function vfBtnWhereB3()	gs.zona = d.b3:get_text();vf4WH()	end
function vfBtnWhereB4()	gs.zona = d.b4:get_text();vf4WH()	end

function vfBtnWhereC1()	gs.zona = d.c1:get_text();vf4WH()	end
function vfBtnWhereC2()	gs.zona = d.c2:get_text();vf4WH()	end
function vfBtnWhereC3()	gs.zona = d.c3:get_text();vf4WH()	end
function vfBtnWhereC4()	gs.zona = d.c4:get_text();vf4WH()	end

-- invert field disposition due team selection
function vfFieldDirection(b)
    d.a1:set_text( iif(b,"D2L","A2R") )
	d.a2:set_text( iif(b,"D5L","A5R") )
	d.a3:set_text( iif(b,"A5L","D5R") )
	d.a4:set_text( iif(b,"A2L","D2R") )
	d.b1:set_text( iif(b,"D2C","A2C") )
	d.b2:set_text( iif(b,"D5C","A5C") )
	d.b3:set_text( iif(b,"A5C","D5C") )
	d.b4:set_text( iif(b,"A2C","D2C") )
	d.c1:set_text( iif(b,"D2R","A2L") )
	d.c2:set_text( iif(b,"D5R","A5L") )
	d.c3:set_text( iif(b,"A5R","D5L") )
    d.c4:set_text( iif(b,"A2R","D2L") )
end 
-- log
--
function vf4WH()
    if string.len(gs.T1) >0  then 
        d.btnT1:set_text(gs.T1) 
        d.btnT2:set_text("^^^") 
        vfFieldDirection(true)
    elseif string.len(gs.T2) >0  then 
        d.btnT2:set_text(gs.T2) 
        d.btnT1:set_text("^^^")
        vfFieldDirection(false)
    else
        d.btnT1:set_text("^^^") 
        d.btnT2:set_text("^^^") 
    end
    
 
    d.lblWhere:set_text("Where: "..gs.zona)
    d.lblWho:set_text("Who: "..gs.who)
    d.lblWhen:set_text("When: "..sfFormatTime(gs.start).." ,ss:".. math.floor(gs.start) )
    
    d.txtNote:set_text(gs.note)
	d.chkTry:set_checked( gs.try=="@" )
    --d.lblWhat:set_text("What:"..gs.what)
    
end
-- save info for tag 
--
function vfBtnWho1()
	gs.start = vlc.var.get(vlc.object.input(), "time")
	gs.who   = gasWho[d.ddTeam1:get_value()]
	gs.T1    = gs.who
	gs.T2    = ""
    vf4WH()
end
-- save info for tag 
--
function vfBtnWho2()
	gs.start = vlc.var.get(vlc.object.input(), "time")
	gs.who   = gasWho[d.ddTeam2:get_value()]
	gs.T1    = ""
	gs.T2    = gs.who
    vf4WH()
end
-- add tag to global array & save db
-- 
function vfBtnAddCut()
	gs.endi = vlc.var.get(vlc.object.input(), "time")

	if gs.start==nil or gs.who==nil or gs.endi<gs.start then return end
	
	gs.what   = gasWhat[d.ddWhat:get_value()]
	gs.result = gasResult[d.ddResult:get_value()]
	gs.try    = d.chkTry:get_checked() and "@" or ""
	gs.note	  = d.txtNote:get_text()

	gs.file   = vlc.strings.decode_uri(string.gsub(vlc.input.item():uri(), "file:///",""))
	gs.name   = string.sub( vlc.input.item():name() ,1 , -5) 
	gs.fstart = math.floor(gs.start)
	gs.fendi  = math.floor(1+ gs.endi)
	gs.str    = gs.who.." "..gs.what..gs.zona..gs.result..gs.try

	-- array dei tag
	gaas[string.sub("00000"..tostring(gs.fstart),-5)] = ofTblShallowCopy(gs)
    
    d.txtNote:set_text("")       ; gs.note=""
	d.chkTry:set_checked( false ); gs.try=""

	vfSavedb()
end
-- go to start tag
--
function vfBtnGoClip(e)
	local h,j,k,v,sel,n
	s = d.lstCuts:get_selection()
	if (not s) then return 1 end
	--vlc.msg.info(table.concat(t,";"))
	--vfLog("go[0]="..d.lstCuts:get_selection()[0])
	for k, v in pairs(s) do
		h = gaasLst[v]
        gs = ofTblShallowCopy(gaas[h])

        vfTablePrint(gs,"gs")
		vlc.var.set(vlc.object.input(), "time", e and gs.endi or gs.start) 
		vf4WH()
		break
	end
end
function vfBtnGoClipEnd()
	vfBtnGoClip(1)
end 
function vfBtnDelClip()
	local h,k,v,s
	s = d.lstCuts:get_selection()
	if (not s) then return 1 end	

	for k,v in pairs(s) do
		h = gaasLst[v]
		gaas[h] = nil
		--vfLog(k.."="..h.."="..gaas[h].start) ---.."="..gaas[tostring(h)])
	end

	vfSavedb()
end
-- http://stackoverflow.com/questions/20282054/how-to-urldecode-a-request-uri-string-in-lua
local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end
local unescape = function(url)
  return url:gsub("%%(%x%x)", hex_to_char)
end
--sanificate file name
function sfSaniUri(s)
  return "\""..string.gsub(s,"/","\\").."\""
end 
-- dos fork simple call hang VLC
function vfFork(sBatFile)
	os.execute("start cmd /k call \""..sBatFile.."\"")
end 
-- create .bat to cut all from global array
--
function vfBtnMp4Cut()
  vfSavedb()
  local k,v,i,ii,t
  local sBatFile = gsBaseDir..gsBaseFile..".bat"
  local sDirMp4 = gsBaseDir..gsBaseFile..".dir"
  local f0,f1,f2,f3,f4,f5
  
  --    -i "c:\20131013 ro pd.AVI" -o "c:\20131013 ro pd.mp4" --start-at duration:10.34 --stop-at duration:5.54
	io.output(sBatFile)
    
    io.write("set hb="..sfSaniUri(gsHandBrake).."\n")
    io.write("set hbflags= -f mp4 -O  -w 480 -l 272 -e x264 -b 700 -2  --vfr  -a none -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subq=6:8x8dct=0:trellis=0 --verbose=1\n") 
	
	i = 1
    t = tonumber(gsTimeShift)
	if t == nil then t = 0 end
    vfLog(t)
	
    --f1 = " -f mp4 -O  -w 480 -l 272 -e x264 -b 700 -2  --vfr  -a none -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:subq=6:8x8dct=0:trellis=0 --verbose=1"
	for k,v in pfPairsByKeys(gaas) do
        if i == 1 then 
            io.write("set ifile="..sfSaniUri(v.file).."\n")
            io.write("set oDir="..sDirMp4.."\n")
            io.write("mkdir \"%oDir%\"\n")
            f0 = "%hb% %hbflags% -i %ifile%"
        end 
		ii = string.sub("00"..tostring(i),-3)
		f1 = " -o \"%oDir%\\"..v.str.."."..gsBaseFile.."."..ii..".mp4\""
		f2 = " --start-at duration:".. tostring(t + v.fstart)
		f3 = " --stop-at duration:".. tostring(v.fendi - v.fstart)
		io.write( f0..f1..f2..f3.."\n")
		
		i = i + 1
	end 
	io.write('@pause\n@exit')
	io.close()
	--vfLog(sBatFile)
	-- dos fork !!
	vfFork(sBatFile)

end
-- create .bat to cut all from global array
-- just cut native container
-- cut with VLC, aware about VLC precision!  vlc sometimes is not very precise in cut!
function vfBtnJCut()
  local k,v,i,ii
  local sVideo   = gsBaseDir..gsVideo
  local sBase    = string.sub(gsVideo,1,-5)
  local sExt     = string.sub(gsVideo,-4,-1)
  local sBatFile = gsBaseDir..sBase..".bat"
  local f0,f1,f2,f3,f4,f5
  
  --    -i "c:\20131013 ro pd.AVI" -o "c:\20131013 ro pd.mp4" --start-at duration:10.34 --stop-at duration:5.54
	io.output(sBatFile)
	io.write("mkdir "..sfSaniUri(gsBaseDir..sBase..".cuts").."\n")
	i = 1

	f0 = "\""..vlc.config.datadir().."\\vlc.exe\" -I dummy -vvv \""..sVideo.."\""
	for k,v in pfPairsByKeys(gaas) do
		ii = string.sub("00"..tostring(i),-3)
		
		f1 = " --start-time ".. tostring(v.start)
		f2 = " --stop-time ".. tostring(v.endi)
		
		sExt = ".mp4"
		--f3 = " --sout=#transcode{vcodec=\"h264\",vb=\"512\",fps=\"23.97\",scale=\"1\",acodec=\"mpga\",ab=\"128\",\"channels=2\",samplerate=\"44100\"}:standard{access=\"file\",mux=\"dummy\","
		--f4 = "dst="..gsBaseDir..sBase..".cuts\\"..v.str.."."..sBase.."."..ii..sExt.."\"} vlc://quit"
		
		f3 = " --sout=#file{dst="..gsBaseDir..sBase..".cuts\\"..v.str.."."..sBase.."."..ii..sExt.."\"}"
		f4 = " :no-sout-rtp-sap :no-sout-standard-sap :sout-keep vlc://quit"

		io.write( f0..f1..f2..f3..f4.."\n")
		
		i = i + 1
	end 
    io.write('@pause\n@exit')
	io.close()
	vfFork(sBatFile)

end
-- create .bat to cut all from global array
-- just cut native container
-- VideoRedo was the top of the mpeg dvd cutter, this is the batch for it
function vfBtnVideoRedo()
  local k,v,i,ii
  local sVideo   = gsBaseDir..gsVideo
  local sBase    = string.sub(gsVideo,1,-5)
  local sExt     = string.sub(gsVideo,-4,-1)
  local sBatFile = gsBaseDir..sBase..".vdr.vbs"
  local f0,f1,f2,f3,f4,f5
  

	io.output(sBatFile)

io.write("Set oFSO = CreateObject(\"Scripting.FileSystemObject\")"                      .."\n")
io.write("If Not oFSO.FolderExists("..gsBaseDir..sBase..".vdr\") Then"                       .."\n")
io.write("oFSO.CreateFolder "..gsBaseDir..sBase..".vdr\""                                    .."\n")
io.write("End If"                                                                       .."\n")
io.write("Set VideoReDo = WScript.CreateObject( \"VideoReDo.Application\" )"			.."\n")
io.write("VideoReDo.FileOpen( \""..sVideo.."\")"                                        .."\n")
io.write("VideoReDo.SetCutMode( FALSE )" 	                                            .."\n")
io.write("sub vfOutputCut( outputFilename, startTime, EndTime )"                        .."\n")
io.write("VideoReDo.ClearAllSelections"                                                 .."\n")
io.write("VideoReDo.SelectScene round(startTime / 10000) , round(EndTime / 10000)"      .."\n")
io.write("VideoReDo.SetQuietMode true"                                                  .."\n")
io.write("VideoReDo.FileSaveAsEx outputFilename, 1 "                                 	.."\n")
io.write("while( VideoReDo.IsOutputInProgress() )"                                      .."\n")
io.write("		Wscript.Sleep 3000"                                                     .."\n")
io.write("wend"                                                                         .."\n")
io.write("VideoReDo.ClearAllSelections"                                                 .."\n")
io.write("end sub"																		.."\n")

	i = 1
	for k,v in pfPairsByKeys(gaas) do
		ii = string.sub("00"..tostring(i),-3)

		f1 = tostring(v.start)
		f2 = tostring(v.endi)

		f0 = gsBaseDir..sBase..".vdr\\"..v.str.."."..sBase.."."..ii..".mpg"

		io.write( "vfOutputCut \""..f0.."\","..f1..","..f2.."\n")
		
		i = i + 1
	end 
	
io.write("VideoReDo.Close\n")
io.write("Wscript.Quit 0\n")
	io.close()
    
end

function vfBtnClipInfo()
	vfLog(vlc.config.datadir())
	vfLog(vlc.config.userdatadir())
	vfLog(vlc.config.homedir())
	vfLog(vlc.config.configdir())
	vfLog("datadir_list:")
	vfTablePrint(vlc.config.datadir_list( "vlc" ))
	--vfTablePrint(vlc.config.datadir_list( "handbrake" ))
	--vfTablePrint(vlc.input.item():info(),"info")
	vfLog(vlc.input.item():name())
	vfLog(sfRealPath(vlc.input.item():uri()))
	vfTablePrint(vlc.input.item():metas(),"metas")
	vfTablePrint(vlc.input.item():stats(),"stats")
	vfTablePrint(vlc.input.item():info(),"info")
end
-- create plaaylist
function vfBtnM3u()
  local k,v,i,ii
  local sVideo   = gsBaseDir..gsVideo
  local sBase    = string.sub(gsVideo,1,-5)
  -- local sM3uFile = gsBaseDir..sBase..".m3u"
  local sM3uFile = unescape(string.gsub(vlc.input.item():uri(), "file:///","")..".m3u") 
  local sBatFile = gsBaseDir..sBase..".bat"
  local f0,f1,f2,f3,f4
  
	io.output(sM3uFile)
	i = 1
    f0 = ""
	for k,v in pfPairsByKeys(gaas) do
		ii = string.sub("00"..tostring(i),-3)
		f1 = "#EXTINF:,"..v.str.." "..ii.." "..v.note
		f2 = "#EXTVLCOPT:start-time="..tostring(v.start)
		f3 = "#EXTVLCOPT:stop-time="..tostring(v.endi)
		f4 = gsVideo
		f0 = f0..f1.."\n"..f2.."\n"..f3.."\n"..f4.."\n"
        io.write( f1.."\n"..f2.."\n"..f3.."\n"..f4.."\n")
		
		i = i + 1
	end 
    
	io.close()
    io.output(sBatFile)
    io.write("@echo off")
    io.write("\n@echo "..sfSaniUri(sM3uFile).." ...Done!")
    io.write('\n@pause\n@exit')
    io.close()
    vfFork(sBatFile)
    
    vfLog(sfSaniUri(sM3uFile) )
    vfLog( gsUri )
    vfLog( gsBaseFile )
	--	vfLog(vlc.input.item():uri() )
	--	local s = vlc.strings.decode_uri(vlc.input.item():uri())
	--	vfLog( s )		
	--	--s="lavispafile:///C:/20131026 fo lz.AVI"
	--	vfLog ( string.gsub(s,"^file:///","") )
	--	vfLog ( string.gsub(s,"\.[^.]+$","") )
    --
	--	vfLog( string.gsub(string.gsub(s,"^file:///",""),"\.[^.]+$","") )
end
-- simil ternario
--
function iif(b,t,f)
	if b then
		return t
	else
		return f
	end
end
-- rewrite all tags
--
function vfSetLst()
  local str,k,v,i
	-- delete lstCut and link table
	d.lstCuts:clear()
	for k,v in pairs(gaasLst) do gaasLst[k]=nil end
	-- recreate list
	i = 1
	for k,v in pfPairsByKeys(gaas) do
		str = string.sub("00"..tostring(i),-2) .." "..v.str.." ["..v.fstart.."-"..v.fendi.."] "..v.note
		gaasLst[str] = k
		d.lstCuts:add_value(str,i)
		i = i + 1
	end 
end
-- base file per i tagli presa dalla text box
--
function vfBaseFileSet()
    local s = d.txtBFile:get_text()
    if string.len(s) > 0 then 
        gsBaseFile = s
    else 
        d.txtBFile:set_text(gsBaseFile)
    end
    vfLog("gsBaseFile="..gsBaseFile)
end
-- base file per i tagli presa dalla text box
--
function vfTimeShiftSet()
    local s = d.txtTShift:get_text()
    if string.len(s) > 0 then 
        gsTimeShift = s
    else 
        d.txtTShift:set_text(gsTimeShift)
    end
    vfLog("gsTimeShift="..gsTimeShift)
end

--save info tag
--
function vfSavedb()
	io.output(gsDBFile)
    io.write("gsBaseFile=")
    vfBaseFileSet()
    vfSerialize (gsBaseFile)
    io.write("\ngsTimeShift=")
    vfTimeShiftSet()
    vfSerialize (gsTimeShift)
	io.write("\ngaas=")
    vfSetLst()
	vfSerialize(gaas)
	io.close()
end
-- serialize table
--
function vfSerialize (o)
	if type(o) == "number" then
        io.write(o)     --io.write(string.gsub(o,",","."))
	elseif type(o) == "string" then
        io.write(string.format("%q", o))
	elseif type(o) == "table" then
        io.write("{\n")
		for k,v in pairs(o) do
			io.write("  [\"", k, "\"] = ")
			vfSerialize(v)
			io.write(",\n")
		end
		io.write("}\n")
      else
        error("cannot serialize a " .. type(o))
	end
end
-- to copy tables
-- http://lua-users.org/wiki/CopyTable
--
function ofTblShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function ofTblDeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
--http://stackoverflow.com/questions/19664666/check-if-a-string-isnt-nil-or-empty-in-lua
function isempty(s)
  return s == nil or s == ''
end
-- *** tools ***
-- from http://www.videolan.org/developers/vlc/share/lua/intf/modules/common.lua
--
-- convert a duration (in seconds) to a string
function sfFormatTime(d)
    return string.format("%02d:%02d:%02d",
                         math.floor(d/3600),
                         math.floor(d/60)%60,
                         math.floor(d%60))
end
-- print a table (recursively)
function vfTablePrint(t,prefix)
    local prefix = prefix or ""
    if not t then
        vfLog(prefix.."/!\\ nil")
    elseif type(t)~=type({}) then 
        vfLog(prefix.."="..t)
    else
   
        for a,b in pfPairsSorted(t) do
            
            if type(b)==type({}) then
                vfLog(prefix.."."..tostring(a))
                vfTablePrint(b,prefix.."."..tostring(a))
            else
                vfLog(prefix.."."..tostring(a).."="..tostring(b))
            end
        end
    end
end
-- sort list
function pfPairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end
-- Iterate over a table in the keys' alphabetical order
function pfPairsSorted(t)
    local s = {}
    for k,_ in pairs(t) do table.insert(s,k) end
    table.sort(s)
    local i = 0
    return function () i = i + 1; return s[i], t[s[i]] end
end
-- log (string, level)
function vfLog(s, l)
    if s == nil then s = "" end
    if l == nil then l = 0  end
    
    text = "["..os.date("%c").."] "..s
    
    if l == 0 then
        vlc.msg.info(text)
    elseif l == 1 then
        vlc.msg.err(text)
    elseif l == 2 then
        vlc.msg.warn(text)
    elseif l == 3 then
        vlc.msg.dbg(text)
    end
end
-- Trigger a hotkey
function vfHotKey(arg)
    local id = vlc.misc.action_id( arg )
    if id ~= nil then
        vlc.var.set( vlc.object.libvlc(), "key-action", id )
        return true
    else
        return false
    end
end
-- realpath
function sfRealPath(path)
    return string.gsub(string.gsub(string.gsub(string.gsub(path,"/%.%./[^/]+","/"),"/[^/]+/%.%./","/"),"/%./","/"),"//","/")
end
-- parse the time from a string and return the seconds
-- time format: [+ or -][<int><H or h>:][<int><M or m or '>:][<int><nothing or S or s or ">]
function sfSec4Time(timestring)
    local seconds = 0
    local hourspattern = "(%d+)[hH]"
    local minutespattern = "(%d+)[mM']"
    local secondspattern = "(%d+)[sS\"]?$"

    local _, _, hoursmatch = string.find(timestring, hourspattern)
    if hoursmatch ~= nil then
        seconds = seconds + tonumber(hoursmatch) * 3600
    end
    local _, _, minutesmatch = string.find(timestring, minutespattern)
    if minutesmatch ~= nil then
        seconds = seconds + tonumber(minutesmatch) * 60
    end
    local _, _, secondsmatch = string.find(timestring, secondspattern)
    if secondsmatch ~= nil then
        seconds = seconds + tonumber(secondsmatch)
    end

    if string.sub(timestring,1,1) == "-" then
        seconds = seconds * -1
    end

    return seconds
end
