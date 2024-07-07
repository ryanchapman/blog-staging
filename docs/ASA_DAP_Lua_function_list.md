---
title: "ASA: DAP LUA function list"
date: "2015-11-07"
redirect_from: "/post/132771415134/asa-dap-lua-function-list"
categories: 
    - "asa"
    - "dap"
    - "lua"
    - "functions"
    - "function list"
---

<p><em>ASA 9.4.2 (which has Lua 5.0.2), AnyConnect 4.0 on iOS</em></p>

<p>
On the internets, I haven't been able to locate a list of Lua functions available for use with Dynamic Access Policies (DAP) on Cisco's ASA firewall. So I decided to just use Lua running on the ASA to tell me what functions and variables are in global scope.  Not quite as good as documentation, but it works for now.
</p>

<p>
To set it up it, open ASDM and
<ul>
<li>Go to Configuration > Remote Access VPN > Dynamic Access Policies</li>
<li>Add</li>
<li>Policy Name: list_globals</li>
<li>Description: prints a list of Lua globals to the ASA CLI</li>
<li>ACL Priority: 50 (or whatever priority you want to assign)</li>
<li>User had ALL of the following AAA Attribute values...</li>
<li>Add (AAA attribute)</li>
<li>AAA Attribute Type: Cisco</li>
<li>Username: rchapmandap (replace with the username you use to sign into AnyConnect)</li>
<li>OK</li>
<li>Click Advanced below the AAA Attributes</li>
<li>Paste in this code:<br/>
<pre>
assert(function()

  DEBUG_DAP_TRACE("============\n")
  DEBUG_DAP_TRACE("GLOBALS\n")

  for k,v in pairs(_G) do
    msg = "k=" .. print_value(k) .. ", v="
    if (type(v) == "function" or type(v) == "table") then
      msg = msg .. tostring(v)
    elseif (type(v) == "string" or type(v) == "number") then
      msg = msg .. v
    elseif (type(v) == "boolean") then
      if (v) then
        msg = msg .. "true"
      else
        msg = msg .. "false"
      end
    end
    msg = msg .. " (" .. type(v) .. ")\n"
    DEBUG_DAP_TRACE(msg)
  end

  return true

end)()
</pre></li>
<li>For Action, make sure Continue is selected</li>
</ul>
</p>

<p>Now that you have it set up, just need to turn dap tracing on in the CLI and log into AnyConnect one time
<ul>
<li>Log into the ASA CLI</li>
<li>Enable dap trace debugging<br/>
<pre>
fw1/pri/act# debug dap trace
debug dap trace enabled at level 1
</pre>
</li>
<li>Open AnyConnect VPN Client on a device and log in to the VPN so that the DAP rules fire once. Log in make take longer than normal as the DAP trace logs to the CLI.</li>
</ul>
</p>

<p>In the ASA CLI, you'll see something like this:<br/>
<pre>
fw1/pri/act# DAP_TRACE: DAP_open: New DAP Request: A4
DAP_TRACE: Username: rchapmandap, DAP_add_SCEP: scep required = [FALSE]
DAP_TRACE: Username: rchapmandap, DAP_add_AC:
endpoint.anyconnect.clientversion = "4.0.03016";
endpoint.anyconnect.platform = "apple-ios";
endpoint.anyconnect.devicetype = "iPhone7,2";
endpoint.anyconnect.platformversion = "9.0.2";
endpoint.anyconnect.deviceuniqueid = "XXXXXXXXXXXXXXXXXXXXXXXXXXXX";
endpoint.anyconnect.phoneid = "UNKNOWN:unknown";
endpoint.anyconnect.macaddress["0"] = "unknown";
endpoint.anyconnect.useragent = "AnyConnect AppleSSLVPN_Darwin_ARM (iPhone) 4.0.03016";

DAP_TRACE: aaa.radius["18"]["1"] = "debug_print"
DAP_TRACE: aaa.radius["25"]["1"] = "OU=Test_VPN;"
DAP_TRACE: aaa["cisco"]["grouppolicy"] = "Test_VPN"
DAP_TRACE: aaa["cisco"]["class"] = "Test_VPN"
DAP_TRACE: aaa["cisco"]["username"] = "rchapmandap"
DAP_TRACE: aaa["cisco"]["username1"] = "rchapmandap"
DAP_TRACE: aaa["cisco"]["username2"] = ""
DAP_TRACE: aaa["cisco"]["tunnelgroup"] = "SplitTunnel"
DAP_TRACE: aaa["cisco"]["sceprequired"] = "false"
DAP_TRACE: endpoint["application"]["clienttype"] = "AnyConnect"
DAP_TRACE: endpoint.anyconnect.clientversion  = "4.0.03016"
DAP_TRACE: endpoint.anyconnect.platform  = "apple-ios"
DAP_TRACE: endpoint.anyconnect.devicetype  = "iPhone7,2"
DAP_TRACE: endpoint.anyconnect.platformversion  = "9.0.2"
DAP_TRACE: endpoint.anyconnect.deviceuniqueid  = "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
DAP_TRACE: endpoint.anyconnect.phoneid  = "UNKNOWN:unknown"
DAP_TRACE: endpoint.anyconnect.macaddress["0"]  = "unknown"
DAP_TRACE: endpoint.anyconnect.useragent  = "AnyConnect AppleSSLVPN_Darwin_ARM (iPhone) 4.0.03016"
DAP_TRACE: ============
DAP_TRACE: GLOBALS
DAP_TRACE: k=EVAL, v=function: 0x00007fffc7c31cb0 (function)
DAP_TRACE: k=tostring, v=function: 0x00007fffc5b9f8c0 (function)
DAP_TRACE: k=gcinfo, v=function: 0x00007fffc5ba03b0 (function)
DAP_TRACE: k=InCommaList, v=function: 0x00007fffc6019f20 (function)
DAP_TRACE: k=os, v=table: 0x00007fffc5ba1480 (table)
DAP_TRACE: k=dap_records, v=table: 0x00007fffac3b0210 (table)
DAP_TRACE: k=smart_table, v=function: 0x00007fffac3b28c0 (function)
DAP_TRACE: k=eval_LT, v=function: 0x00007fffc601b800 (function)
DAP_TRACE: k=getfenv, v=function: 0x00007fffc5b9f310 (function)
DAP_TRACE: k=p, v=Test_VPN (string)
DAP_TRACE: k=pairs, v=function: 0x00007fffc5b9f650 (function)
DAP_TRACE: k=_TRACEBACK, v=function: 0x00007fffc5ba6e60 (function)
DAP_TRACE: k=assert, v=function: 0x00007fffc5b9fa60 (function)
DAP_TRACE: k=eval_NE, v=function: 0x00007fffc5723950 (function)
DAP_TRACE: k=tonumber, v=function: 0x00007fffc5b9f7f0 (function)
DAP_TRACE: k=print_dap_trees, v=function: 0x00007fffc5627ec0 (function)
DAP_TRACE: k=io, v=table: 0x00007fffc5ba2c90 (table)
DAP_TRACE: k=count, v=1 (number)
DAP_TRACE: k=escape_string, v=function: 0x00007fffac6901d0 (function)
DAP_TRACE: k=lxp, v=table: 0x00007fffc5ba7900 (table)
DAP_TRACE: k=_LOADED, v=table: 0x00007fffc5ba1330 (table)
DAP_TRACE: k=_G, v=table: 0x00007fffc5a73950 (table)
DAP_TRACE: k=coroutine, v=table: 0x00007fffc5ba0d50 (table)
DAP_TRACE: k=install_name_value_pair, v=function: 0x00007fffac690240 (function)
DAP_TRACE: k=versionCompare, v=function: 0x00007fffc6019eb0 (function)
DAP_TRACE: k=eval_GT, v=function: 0x00007fffc5bbc810 (function)
DAP_TRACE: k=loadstring, v=function: 0x00007fffc5ba0620 (function)
DAP_TRACE: k=soap, v=table: 0x00007fffc5baec10 (table)
DAP_TRACE: k=CheckAndMsg, v=function: 0x00007fffb97f4140 (function)
DAP_TRACE: k=string, v=table: 0x00007fffc5ba47a0 (table)
DAP_TRACE: k=xpcall, v=function: 0x00007fffc5a73be0 (function)
DAP_TRACE: k=evaluate_dap_record, v=function: 0x00007fffb9223990 (function)
DAP_TRACE: k=_VERSION, v=Lua 5.0.2 (string)
DAP_TRACE: k=endpoint, v=table: 0x00007fffb973d760 (table)
DAP_TRACE: k=unpack, v=function: 0x00007fffc5b9fb30 (function)
DAP_TRACE: k=oper, v=table: 0x00007fffac68b840 (table)
DAP_TRACE: k=require, v=function: 0x00007fffc5ba06f0 (function)
DAP_TRACE: k=ret, v=true (boolean)
DAP_TRACE: k=install_endpoint_data, v=function: 0x00007fffc63e8350 (function)
DAP_TRACE: k=setmetatable, v=function: 0x00007fffc5b9f240 (function)
DAP_TRACE: k=next, v=function: 0x00007fffc5b9f4b0 (function)
DAP_TRACE: k=indent, v=function: 0x00007fffc646b290 (function)
DAP_TRACE: k=aaa, v=table: 0x00007fffb97f5530 (table)
DAP_TRACE: k=ipairs, v=function: 0x00007fffc5b9f580 (function)
DAP_TRACE: k=init_session_tables, v=function: 0x00007fffac3b3de0 (function)
DAP_TRACE: k=msg, v=k=init_session_tables, v=function: 0x00007fffac3b3de0 (function)
 (string)
DAP_TRACE: k=rawequal, v=function: 0x00007fffc5b9fc00 (function)
DAP_TRACE: k=lua_dap_debug_trace, v=function: 0x00007fffc5baeda0 (function)
DAP_TRACE: k=collectgarbage, v=function: 0x00007fffc5ba02e0 (function)
DAP_TRACE: k=result, v=true (boolean)
DAP_TRACE: k=newproxy, v=function: 0x00007fffc5ba0c70 (function)
DAP_TRACE: k=matchcount, v=1 (number)
DAP_TRACE: k=eval_EQ, v=function: 0x00007fffac171d30 (function)
DAP_TRACE: k=print_table, v=function: 0x00007fffc6355300 (function)
DAP_TRACE: k=dap_names, v=table: 0x00007fffac3b0290 (table)
DAP_TRACE: k=dap_messages, v=table: 0x00007fffb9f8bb60 (table)
DAP_TRACE: k=eval_LE, v=function: 0x00007fffc5730180 (function)
DAP_TRACE: k=rawset, v=function: 0x00007fffc5a73a40 (function)
DAP_TRACE: k=EVALone, v=function: 0x00007fffc7c31c40 (function)
DAP_TRACE: k=_, v=1 (number)
DAP_TRACE: k=getmetatable, v=function: 0x00007fffc5b9f170 (function)
DAP_TRACE: k=callbacks, v=table: 0x00007fffac5f8400 (table)
DAP_TRACE: k=mt, v=table: 0x00007fffac5f5e80 (table)
DAP_TRACE: k=table, v=table: 0x00007fffc5ba5550 (table)
DAP_TRACE: k=pcall, v=function: 0x00007fffc5a73b10 (function)
DAP_TRACE: k=print_tree, v=function: 0x00007fffc5627e50 (function)
DAP_TRACE: k=DEBUG_DAP_TRACE, v=function: 0x00007fffc64fd1b0 (function)
DAP_TRACE: k=type, v=function: 0x00007fffc5b9f990 (function)
DAP_TRACE: k=print_value, v=function: 0x00007fffc6571520 (function)
DAP_TRACE: k=dump_lua, v=function: 0x00007fffc6525ae0 (function)
DAP_TRACE: k=get_selected_daps, v=function: 0x00007fffc6525a70 (function)
DAP_TRACE: k=eval_GE, v=function: 0x00007fffc64690c0 (function)
DAP_TRACE: k=dapxmlxlate, v=function: 0x00007fffac3b3e50 (function)
DAP_TRACE: k=rawget, v=function: 0x00007fffc5b9fcd0 (function)
DAP_TRACE: k=application, v=table: 0x00007fffbbff7210 (table)
DAP_TRACE: k=debug, v=table: 0x00007fffc5ba0900 (table)
DAP_TRACE: k=print, v=function: 0x00007fffc5b9f720 (function)
DAP_TRACE: k=setfenv, v=function: 0x00007fffc5b9f3e0 (function)
DAP_TRACE: k=sign, v=table: 0x00007fffac170bc0 (table)
DAP_TRACE: k=dofile, v=function: 0x00007fffc5ba0550 (function)
DAP_TRACE: k=error, v=function: 0x00007fffc5b9f0a0 (function)
DAP_TRACE: k=loadfile, v=function: 0x00007fffc5ba0480 (function)
DAP_TRACE: Username: rchapmandap, Selected DAPs: ,msg_Welcome,msg_tunnel_type,list_globals
DAP_TRACE: dap_process_selected_daps: selected 3 records
DAP_TRACE: Username: rchapmandap, dap_aggregate_attr: rec_count = 3
DAP_TRACE: Username: rchapmandap, DAP_close: A4
</pre>
</p>

<p>I'm sure there is more info to be found, but this is all I have time for now.  If you find more, please share in the comments...</p>

