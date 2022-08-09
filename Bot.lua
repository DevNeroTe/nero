
https = require ("ssl.https") 
serpent = dofile("./lib/serpent.lua") 
json = dofile("./lib/JSON.lua") 
JSON  = dofile("./lib/dkjson.lua")
URL = dofile("./lib/url.lua")
database = dofile("./lib/redis.lua").connect("127.0.0.1", 6379)
id_server = io.popen("echo $SSH_CLIENT ¦ awk '{ print $1}'"):read('*a')
--------------------------------------------------------------------------------------------------------------
local AutoSet = function() 
local create = function(data, file, uglify)  
file = io.open(file, "w+")   
local serialized   
if not uglify then  
serialized = serpent.block(data, {comment = false, name = "Info"})  
else  
serialized = serpent.dump(data)  
end    
file:write(serialized)    
file:close()  
end  
if not database:get(id_server..":token") then
io.write('\27[1;35m\n ارسل لي توكن البوت الان ↓ :\n\27[0;33;49m')
local token = io.read()
if token ~= '' then
local url , res = https.request('https://api.telegram.org/bot'..token..'/getMe')
if res ~= 200 then
print('\27[1;31m==========================\n التوكن غير صحيح تاكد منه ثم ارسله')
else
io.write('\27[1;36m تم حفظ التوكن بنجاح \n27[0;39;49m')
database:set(id_server..":token",token)
end 
else
print('\27[1;31m==========================\n لم يتم حفظ التوكن ارسل لي التوكن الان')
end 
os.execute('lua Storm.lua')
end
if not database:get(id_server..":SUDO:ID") then
io.write('\27[1;35m\n ارسل لي ايدي Carbon الاساسي ↓ :\n\27[0;33;49m')
local SUDOID = io.read()
if SUDOID ~= '' then
io.write('\27[1;36m تم حفظ ايدي Carbon الاساسي \n27[0;39;49m')
database:set(id_server..":SUDO:ID",SUDOID)
else
print('\27[1;31m==========================\n لم يتم حفظ ايدي Carbon الاساسي ارسله مره اخره')
end 
os.execute('lua Storm.lua')
end
local create_config_auto = function()
config = {
token = database:get(id_server..":token"),
SUDO = database:get(id_server..":SUDO:ID"),
 }
create(config, "./Info_Sudo.lua")   
end 
create_config_auto()
file = io.open("Runn", "w")  
file:write([[
#!/usr/bin/env bash
cd $HOME/Botf
token="]]..database:get(id_server..":token")..[["
while(true) do
rm -fr ../.telegram-cli
function print_logo() {
}
if [ ! -f ./tg ]; then
echo "=============================================="
echo "TG IS NOT FIND IN FILES BOT"
echo "=============================================="
exit 1
fi
if [ ! $token ]; then
echo "=============================================="
echo -e "\e[1;36mTOKEN IS NOT FIND IN FILE INFO.LUA \e[0m"
echo "=============================================="
exit 1
fi
print_logo
echo -e "\033[38;5;208m"
echo -e "                                                  "
echo -e "\033[0;00m"
echo -e "\e[36m"
./tg -s ./Bot.lua -p PROFILE --bot=$token
done
]])  
file:close()  
file = io.open("Run", "w")  
file:write([[
#!/usr/bin/env bash
cd $HOME/Botf
while(true) do
rm -fr ../.telegram-cli
screen -S Botf -X kill
screen -S Botf ./Runn
done
]])  
file:close() 
os.execute('rm -fr $HOME/.telegram-cli')
end 
local serialize_to_file = function(data, file, uglify)  
file = io.open(file, "w+")  
local serialized  
if not uglify then   
serialized = serpent.block(data, {comment = false, name = "Info"})  
else   
serialized = serpent.dump(data) 
end  
file:write(serialized)  
file:close() 
end 
local load_redis = function()  
local f = io.open("./Info_Sudo.lua", "r")  
if not f then   
AutoSet()  
else   
f:close()  
database:del(id_server..":token")
database:del(id_server..":SUDO:ID")
end  
local config = loadfile("./Info_Sudo.lua")() 
return config 
end 
_redis = load_redis()  
--------------------------------------------------------------------------------------------------------------
sudos = dofile("./Info_Sudo.lua") 
SUDO = tonumber(sudos.SUDO)
sudo_users = {SUDO}
bot_id = sudos.token:match("(%d+)")  
token = sudos.token 
--- start functions ↓
--------------------------------------------------------------------------------------------------------------
function vardump(value)  
print(serpent.block(value, {comment=false}))   
end 
function SudoBot(msg)  
local FDFGERB = false  
for k,v in pairs(sudo_users) do  
if tonumber(msg.sender_user_id_) == tonumber(v) then  
FDFGERB = true  
end  
end  
return FDFGERB  
end 
function dl_cb(a,d)
end
function getChatId(id)
local chat = {}
local id = tostring(id)
if id:match('^-100') then
local channel_id = id:gsub('-100', '')
chat = {ID = channel_id, type = 'channel'}
else
local group_id = id:gsub('-', '')
chat = {ID = group_id, type = 'group'}
end
return chat
end
local function send(chat_id, reply_to_message_id, text)
local TextParseMode = {ID = "TextParseModeMarkdown"}
tdcli_function ({ID = "SendMessage",chat_id_ = chat_id,reply_to_message_id_ = reply_to_message_id,disable_notification_ = 1,from_background_ = 1,reply_markup_ = nil,input_message_content_ = {ID = "InputMessageText",text_ = text,disable_web_page_preview_ = 1,clear_draft_ = 0,entities_ = {},parse_mode_ = TextParseMode,},}, dl_cb, nil)
end
function s_api(web) 
local info, res = https.request(web) local req = json:decode(info) if res ~= 200 then return false end if not req.ok then return false end return req 
end 
local function sendText(chat_id, text, reply_to_message_id, markdown) 
send_api = "https://api.telegram.org/bot"..token local url = send_api..'/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text) if reply_to_message_id ~= 0 then url = url .. '&reply_to_message_id=' .. reply_to_message_id  end if markdown == 'md' or markdown == 'markdown' then url = url..'&parse_mode=Markdown' elseif markdown == 'html' then url = url..'&parse_mode=HTML' end return s_api(url)  
end
function send_inline_key(chat_id,text,keyboard,inline,reply_id) 
local response = {} response.keyboard = keyboard response.inline_keyboard = inline response.resize_keyboard = true response.one_time_keyboard = false response.selective = false  local send_api = "https://api.telegram.org/bot"..token.."/sendMessage?chat_id="..chat_id.."&text="..URL.escape(text).."&parse_mode=Markdown&disable_web_page_preview=true&reply_markup="..URL.escape(JSON.encode(response)) if reply_id then send_api = send_api.."&reply_to_message_id="..reply_id end return s_api(send_api) 
end
local function GetInputFile(file)  
local file = file or ""   if file:match('/') then  infile = {ID= "InputFileLocal", path_  = file}  elseif file:match('^%d+$') then  infile = {ID= "InputFileId", id_ = file}  else  infile = {ID= "InputFilePersistentId", persistent_id_ = file}  end return infile 
end
function scandirfile(directory)
local i, t, popen = 0, {}, io.popen
for filename in popen('ls '..directory..''):lines() do
i = i + 1
t[i] = filename
end
return t
end
function exi_filesx(cpath)
local files = {}
local pth = cpath
for k, v in pairs(scandirfile(pth)) do
table.insert(files, v)
end
return files
end
function file_exia(name, cpath)
for k,v in pairs(exi_filesx(cpath)) do
if name == v then
return true
end
end
return false
end
--------------------------------------------------------------------------------------------------------------
function Sourcebottext(msg,data) -- بداية العمل
if msg then
local text = msg.content_.text_
--------------------------------------------------------------------------------------------------------------
if msg.chat_id_ then
local id = tostring(msg.chat_id_)
if id:match("-100(%d+)") then
database:incr(bot_id..'Msg_User'..msg.chat_id_..':'..msg.sender_user_id_) 
Chat_Type = 'GroupBot' 
elseif id:match("^(%d+)") then
database:sadd(bot_id..'User_Bot',msg.sender_user_id_)  
Chat_Type = 'UserBot' 
else
Chat_Type = 'GroupBot' 
end
end
--------------------------------------------------------------------------------------------------------------
if Chat_Type == 'UserBot' then
if SudoBot(msg) then
if text == '/start' then  
local bl = ' اهلا بك عزيزي Carbon في اوامر الكيبورد'
local keyboard = {
{'حذف بوت','انشاء بوت'},
{'السكرينات','غلق سكرين'},
{'السيرفر','المشتركين','الملفات'},
{"تحديث ♻"},
{'الغاء'}
}
send_inline_key(msg.chat_id_,bl,keyboard)
return false
end
if text == 'تحديث ♻' then    
dofile('Bot.lua')  
send(msg.chat_id_, msg.id_, ' تم تحديث البوت') 
return false
end 
if text == 'انشاء بوت' then
send(msg.chat_id_, msg.id_, ' ارسل لي التواكن الان') 
database:set(bot_id.."Send:Token"..msg.chat_id_..":"..msg.sender_user_id_,'true') 
return false
end
if database:get(bot_id.."Send:Token"..msg.chat_id_..":"..msg.sender_user_id_) == 'true' then
if text == 'الغاء' then
send(msg.chat_id_, msg.id_, 'Done Cancell Command') 
database:del(bot_id.."Send:Token"..msg.chat_id_..":"..msg.sender_user_id_)
return false
end
if text and text:match("^(%d+)(:)(.*)") then
local url , res = https.request('https://api.telegram.org/bot'..text..'/getMe')
local Json_Info = JSON.decode(url)
if Json_Info.ok == false then
send(msg.chat_id_, msg.id_, '\n التوكن غير صحيح ? \n ارسله مره اخره او ارسل الغاءمن الكيبورد !') 
return false
else
NameBot = Json_Info.result.first_name
UserNameBot = Json_Info.result.username
NameBot = NameBot:gsub('"','') 
NameBot = NameBot:gsub("'",'') 
NameBot = NameBot:gsub('`','') 
NameBot = NameBot:gsub('*','') 
send(msg.chat_id_, msg.id_, '\n تم حفظ التوكن بنجاح \n اسم البوت ['..NameBot..']\n معرف البوت [@'..UserNameBot..']\n الان ارسل معرف المستخدم ') 
database:del(bot_id.."Send:Token"..msg.chat_id_..":"..msg.sender_user_id_) 
database:set(bot_id.."Send:UserName"..msg.chat_id_..":"..msg.sender_user_id_,'true1') 
database:set(bot_id.."Token:Bot"..msg.chat_id_..":"..msg.sender_user_id_,text) 
return false
end
end
end
if database:get(bot_id.."Send:UserName"..msg.chat_id_..":"..msg.sender_user_id_) == 'true1' then
if file_exia(text,'/root') then
send(msg.chat_id_, msg.id_, ' عذرا يوجد بوت بهاذا المعرف ارسل المعرف مره ثانيه او ارسل من الكيبورد الغاء!') 
return false  
end 
if text == 'الغاء' then
send(msg.chat_id_, msg.id_, 'Done Cancell Command') 
database:del(bot_id.."Send:UserName"..msg.chat_id_..":"..msg.sender_user_id_) 
return false  
end 
local username = string.match(text, "@[%a%d_]+") 
if username then
tdcli_function({ID = "SearchPublicChat",username_ = username},function(arg,data) 
if data and data.message_ and data.message_ == "USERNAME_NOT_OCCUPIED" then 
send(msg.chat_id_, msg.id_, 'المعرف لا يوجد فيه قناة\n ارسله مره اخره او ارسل الغاءمن الكيبورد !')
return false  
end
if data.type_.user_.type_.ID == "UserTypeBot" then
send(msg.chat_id_, msg.id_,' لا تستطيع وضع معرفات البوتات\n ارسله مره اخره او ارسل الغاءمن الكيبورد !') 
return false  
end
if data and data.type_ and data.type_.channel_ and data.type_.channel_.ID == "Channel" then
send(msg.chat_id_, msg.id_,' عذا لا يمكنك وضع معرف قناة في الاشتراك \n ارسله مره اخره او ارسل الغاءمن الكيبورد !') 
return false  
end
if data and data.type_ and data.type_.channel_ and data.type_.channel_.is_supergroup_ == true then
send(msg.chat_id_, msg.id_,' عذا لا يمكنك وضع معرف مجوعه في الاشتراك \n ارسله مره اخره او ارسل الغاءمن الكيبورد !') 
return false  
end
if data and data.type_ and data.type_.ID and data.type_.ID == 'PrivateChatInfo' then
send(msg.chat_id_, msg.id_, 'Done Save UserName ') 
send(msg.chat_id_, msg.id_, 'Bot Was Start...') 
database:del(bot_id.."Send:UserName"..msg.chat_id_..":"..msg.sender_user_id_) 
database:set(bot_id.."Sudo:Bot"..msg.chat_id_..":"..msg.sender_user_id_,data.id_) 
Token = database:get(bot_id.."Token:Bot"..msg.chat_id_..":"..msg.sender_user_id_) 
FolderBot = text:gsub('@','') 
database:set(bot_id.."FolderBot"..msg.chat_id_..":"..msg.sender_user_id_,FolderBot) 
Sudo  = data.id_
file = io.open("./Files_Bot/config.lua", "w")  
file:write([[
do 
local File_Info = {
SUDO = "]]..Sudo..[[",
username = "@]]..FolderBot..[[",
sudo_users = {SUDO}, 
token = "]]..Token..[["
}
return File_Info
end

]])
file:close() 
file = io.open("./Files_Bot/Runf", "w")  
file:write([[
#!/usr/bin/env bash
cd $HOME/]]..FolderBot..[[

token="]]..Token..[["
while(true) do
rm -fr ../.telegram-cli
function print_logo() {
echo " BOT"
}
if [ ! -f ./tg ]; then
echo "TG IS NOT FIND IN FILES BOT"
exit 1
fi
if [ ! $token ]; then
echo -e "\e[1;36mTOKEN IS NOT FIND IN FILE INFO.LUA \e[0m"
exit 1
fi
print_logo
echo -e "\033[38;5;208m"
echo -e "                                                  "
echo -e "\033[0;00m"
echo -e "\e[36m"
./tg -s ./FAEDER.lua -p PROFILE --bot=$token
done
]])  
file:close()  
file = io.open("./Files_Bot/run", "w")  
file:write([[
#!/usr/bin/env bash
rm -fr ../.telegram-cli
screen -d -m -S ]]..FolderBot..[[ ./Runf R
]])  
file:close() 
os.execute('cp -a ./Files_Bot/. ../'..FolderBot..' && cd ../'..FolderBot..' && chmod +x install && chmod +x tg && ./install')
print('cp -a ./Files_Bot/. ../'..FolderBot..' && cd ../'..FolderBot..' && chmod +x FDFGERB && screen -d -m -S '..FolderBot..' ./FDFGERB R')
return false  
end
end,nil)
end
end
if text == 'حذف بوت' then
database:set(bot_id.."Del:Screen:And:Bot"..msg.chat_id_..":"..msg.sender_user_id_,'true') 
send(msg.chat_id_, msg.id_,'Send Bot Name Or Carbon User')
return false
end
if database:get(bot_id.."Del:Screen:And:Bot"..msg.chat_id_..":"..msg.sender_user_id_) == 'true' then
if text == 'الغاء' then
send(msg.chat_id_, msg.id_, 'Done Cancell Command') 
database:del(bot_id.."Del:Screen:And:Bot"..msg.chat_id_..":"..msg.sender_user_id_) 
return false  
end 
if file_exia(text,'/root') then
send(msg.chat_id_, msg.id_,'Done Dellete Bot File')
os.execute('rm -fr ~/'..text)
os.execute('screen -S '..text..' -X kill')
database:del(bot_id.."Del:Screen:And:Bot"..msg.chat_id_..":"..msg.sender_user_id_)
else
send(msg.chat_id_, msg.id_,'Erorr Found File Name \n Send الغاء For Cancell')
end
end

if text == 'غلق سكرين' then
database:set(bot_id.."Del:Screen"..msg.chat_id_..":"..msg.sender_user_id_,'true') 
send(msg.chat_id_, msg.id_,' ارسل السكرين الان')
return false
end
if database:get(bot_id.."Del:Screen"..msg.chat_id_..":"..msg.sender_user_id_) == 'true' then
if text == 'الغاء' then
send(msg.chat_id_, msg.id_, 'Done Cancell Command') 
database:del(bot_id.."Del:Screen"..msg.chat_id_..":"..msg.sender_user_id_) 
return false  
end 
if text and text:match("^(%d+)(.)(.*)") then
if text:find('Botf') then
send(msg.chat_id_, msg.id_, ' عذرا هاذا سكرين لوحة التنصيب\n اوسل اسم السكرين مره اخره او ارسل من الكيبورد الغاء') 
return false 
end 
database:del(bot_id.."Del:Screen"..msg.chat_id_..":"..msg.sender_user_id_) 
send(msg.chat_id_, msg.id_, ' تم حذف السكرين وايقاف البوت')
os.execute('screen -S '..text..' -X kill')
return false  
end 
end 
if text == 'السكرينات' then
i = 0
local t = ' Screen List \n· · • • • ⍒ • • • · · \n'
for v in io.popen('ls /var/run/screen/S-root'):lines() do
i = i + 1
t = t..i..'- { `'..v..'` }\n'
end
send(msg.chat_id_, msg.id_,t)
return false
end
if text == 'الملفات' then
local i = 0
local t = ' Bot List \n· · • • • ⍒ • • • · · \n'
for v in io.popen('ls /root'):lines() do
i = i +1
t = t..'*'..i..'- * `'..v..'` \n' 
end 
send(msg.chat_id_, msg.id_,t)
return false
end
if text == 'المشتركين' then
local i = 0
local t = 'Sub List \n \n· · • • • ⍒ • • • · · \n'
for v in io.popen('ls /root'):lines() do
i = i +1
t = t..'*'..i..'- * [@'..v..'] \n' 
end 
send(msg.chat_id_, msg.id_,t)
return false
end
if text == 'السيرفر' then
p = io.popen([[
linux_version=`lsb_release -ds`
memUsedPrc=`free -m  awk 'NR==2{printf "%sMB/%sMB {%.2f%}\n", $3,$2,$3*100/$2 }'`
HardDisk=`df -lh  awk '{if ($6 == "/") { print $3"/"$2" ~ {"$5"}" }}'`
CPUPer=`top -b -n1  grep "Cpu(s)"  awk '{print $2 + $4}'`
uptime=`uptime  awk -F'( ,:)+' '{if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"days,",h+0,"hours,",m+0,"minutes."}'`
echo '        · • • • ⍒ • • • · · { نظام التشغيل } \n* »  '"$linux_version"'*' 
echo '*· · • • • ⍒ • • • · · \n*  { الذاكره العشوائيه } \n* »  '"$memUsedPrc"'*'
echo '*· · • • • ⍒ • • • · · \n*  { وحـده الـتـخـزيـن } \n* »  '"$HardDisk"'*'
echo '*· · • • • ⍒ • • • · · \n*  { الـمــعــالــج } \n* »  '"`grep -c processor /proc/cpuinfo`""Core ~ {$CPUPer%} "'*'
echo '*· · • • • ⍒ • • • · · \n*  { الــدخــول } \n* »  '`whoami`'*'
echo '*· · • • • ⍒ • • • · · \n*  { مـده تـشغيـل الـسـيـرفـر }   \n* »  '"$uptime"'*'
]]):read('*all')
send(msg.chat_id_, msg.id_,p)
return false
end







end -- sudo
end -- type
end -- end msg
end --end 
--------------------------------------------------------------------------------------------------------------
function tdcli_update_callback(data)  -- clback
if data.ID == "UpdateNewMessage" then  -- new msg
msg = data.message_
text = msg.content_.text_
--------------------------------------------------------------------------------------------------------------

if tonumber(msg.sender_user_id_) == tonumber(bot_id) then
return false
end
--------------------------------------------------------------------------------------------------------------
Sourcebottext(data.message_,data)
--------------------------------------------------------------------------------------------------------------
elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then 
end -- end new msg
end -- end callback
















