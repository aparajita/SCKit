#!/usr/bin/env objj

var FILE = require("file"),
    FileList = require("jake").FileList,
    OS = require("os"),
    sleep = OS.sleep,
    SYS = require("system"),
    args = SYS.args,
    ARRAY = require("narwhal/util").array,
    
    nibInfo = {};
    

function getModifiedNibs(path)
{
    var nibs = new FileList(FILE.join(path, "*.xib")).items(),
        count = nibs.length,
        newNibInfo = {},
        modifiedNibs = [];
    
    while (count--)
    {
        var nib = nibs[count];
        
        newNibInfo[nib] = FILE.mtime(nib);
        
        if (!nibInfo.hasOwnProperty(nib))
        {
            modifiedNibs.push(nib);
            CPLog.info(">>> Added: " + nib);
        }
        else
        {            
            if (newNibInfo[nib] - nibInfo[nib] !== 0)
            {
                CPLog.info(">>> Modified: " + nib);
                modifiedNibs.push(nib);
            }
                
            // Remove matching nibs so that we leave
            // deleted nibs in nibInfo.
            delete nibInfo[nib];
        }
    }
    
    for (var nib in nibInfo)
    {
        if (nibInfo.hasOwnProperty(nib))
            CPLog.info(">>> Deleted: " + nib);
    }
    
    nibInfo = newNibInfo;
    
    return modifiedNibs;
}

function main(args)
{
    CPLogRegister(CPLogPrint, "debug", logFormatter);
    
    var dir = FILE.canonical(args[1] || ".");
        
    if (!FILE.isDirectory(dir))
        fail("Cannot find the directory: " + dir);
        
    CPLog.info("Watching %s...", dir);
        
    while (true)
    {
        var modifiedNibs = getModifiedNibs(dir);
        
        sleep(1);
    }
}

function logFormatter(aString, aLevel, aTitle)
{
    if (aLevel === "info")
        return aString;
    else
        return CPLogColorize(aString, aLevel);
}

function fail(msg)
{
    CPLog.error(msg);
    OS.exit(1);
}