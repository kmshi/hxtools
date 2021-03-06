package helpers;


import haxe.io.BytesOutput;
import haxe.io.Eof;
import haxe.io.Path;
import project.Platform;
import sys.io.Process;
import sys.FileSystem;


class ProcessHelper {
	
	
	public static function openFile (workingDirectory:String, targetPath:String, executable:String = ""):Void {
		
		if (executable == null) { 
			
			executable = "";
			
		}
		
		if (PlatformHelper.hostPlatform == Platform.WINDOWS) {
			
			if (executable == "") {
				
				if (targetPath.indexOf (":\\") == -1) {
					
					runCommand (workingDirectory, targetPath, []);
					
				} else {
					
					runCommand (workingDirectory, ".\\" + targetPath, []);
					
				}
				
			} else {
				
				if (targetPath.indexOf (":\\") == -1) {
					
					runCommand (workingDirectory, executable, [ targetPath ]);
					
				} else {
					
					runCommand (workingDirectory, executable, [ ".\\" + targetPath ]);
					
				}
				
			}
			
		} else if (PlatformHelper.hostPlatform == Platform.MAC) {
			
			if (executable == "") {
				
				executable = "/usr/bin/open";
				
			}
			
			if (targetPath.substr (0) == "/") {
				
				runCommand (workingDirectory, executable, [ targetPath ]);
				
			} else {
				
				runCommand (workingDirectory, executable, [ "./" + targetPath ]);
				
			}
			
		} else {
			
			if (executable == "") {
				
				executable = "/usr/bin/xdg-open";
				
			}
			
			if (targetPath.substr (0) == "/") {
				
				runCommand (workingDirectory, executable, [ targetPath ]);
				
			} else {
				
				runCommand (workingDirectory, executable, [ "./" + targetPath ]);
				
			}
			
		}
		
	}
	
	
	public static function openURL (url:String):Void {
		
		if (PlatformHelper.hostPlatform == Platform.WINDOWS) {
			
			runCommand ("", "start", [ url ]);
			
		} else if (PlatformHelper.hostPlatform == Platform.MAC) {
			
			runCommand ("", "/usr/bin/open", [ url ]);
			
		} else {
			
			runCommand ("", "/usr/bin/xdg-open", [ url ]);
			
		}
		
	}
	
	
	public static function runCommand (path:String, command:String, args:Array <String>, safeExecute:Bool = true, ignoreErrors:Bool = false, print:Bool = false):Int {
		
		if (print) {
			
			var message = command;
			
			for (arg in args) {
				
				if (arg.indexOf (" ") > -1) {
					
					message += " \"" + arg + "\"";
					
				} else {
					
					message += " " + arg;
					
				}
				
			}
			
			Sys.println (message);
			
		}
		
		command = PathHelper.escape (command);
		
		if (safeExecute) {
			
			try {
				
				if (path != null && path != "" && !FileSystem.exists (FileSystem.fullPath (path)) && !FileSystem.exists (FileSystem.fullPath (new Path (path).dir))) {
					
					LogHelper.error ("The specified target path \"" + path + "\" does not exist");
					return 1;
					
				}
				
				return _runCommand (path, command, args);
				
			} catch (e:Dynamic) {
				
				if (!ignoreErrors) {
					
					LogHelper.error ("", e);
					return 1;
					
				}
				
				return 0;
				
			}
			
		} else {
			
			return _runCommand (path, command, args);
			
		}
	  
	}
	
	
	private static function _runCommand (path:String, command:String, args:Array<String>):Int {
		
		var oldPath:String = "";
		
		if (path != null && path != "") {
			
			LogHelper.info ("", " - Changing directory: " + path + "");
			
			oldPath = Sys.getCwd ();
			Sys.setCwd (path);
			
		}
		
		var argString = "";
		
		for (arg in args) {
			
			if (arg.indexOf (" ") > -1) {
				
				argString += " \"" + arg + "\"";
				
			} else {
				
				argString += " " + arg;
				
			}
			
		}
		
		LogHelper.info ("", " - Running command: " + command + argString);
		
		var result = 0;
		
		if (args != null && args.length > 0) {
			
			result = Sys.command (command, args);
			
		} else {
			
			result = Sys.command (command);
			
		}
		
		if (oldPath != "") {
			
			Sys.setCwd (oldPath);
			
		}
		
		if (result != 0) {
			
			throw ("Error running: " + command + " " + args.join (" ") + " [" + path + "]");
			
		}
		
		return result;
		
	}
	
	
	public static function runProcess (path:String, command:String, args:Array <String>, waitForOutput:Bool = true, safeExecute:Bool = true, ignoreErrors:Bool = false, print:Bool = false):String {
		
		if (print) {
			
			var message = command;
			
			for (arg in args) {
				
				if (arg.indexOf (" ") > -1) {
					
					message += " \"" + arg + "\"";
					
				} else {
					
					message += " " + arg;
					
				}
				
			}
			
			Sys.println (message);
			
		}
		
		if (PlatformHelper.hostPlatform == Platform.WINDOWS) {
			
			command = StringTools.replace (command, ",", "^,");
			
		}
		
		if (safeExecute) {
			
			try {
				
				if (path != null && path != "" && !FileSystem.exists (FileSystem.fullPath (path)) && !FileSystem.exists (FileSystem.fullPath (new Path (path).dir))) {
					
					LogHelper.error ("The specified target path \"" + path + "\" does not exist");
					
				}
				
				return _runProcess (path, command, args, waitForOutput);
				
			} catch (e:Dynamic) {
				
				if (!ignoreErrors) {
					
					LogHelper.error ("", e);
					
				}
				
				return null;
				
			}
			
		} else {
			
			return _runProcess (path, command, args, waitForOutput);
			
		}
		
	}
	
	
	private static function _runProcess (path:String, command:String, args:Array<String>, waitForOutput:Bool):String {
		
		var oldPath:String = "";
		
		if (path != null && path != "") {
			
			LogHelper.info ("", " - Changing directory: " + path + "");
			
			oldPath = Sys.getCwd ();
			Sys.setCwd (path);
			
		}
		
		var argString = "";
		
		for (arg in args) {
			
			if (arg.indexOf (" ") > -1) {
				
				argString += " \"" + arg + "\"";
				
			} else {
				
				argString += " " + arg;
				
			}
			
		}
		
		LogHelper.info ("", " - Running process: " + command + argString);
		
		var output = "";
		var result = 0;
		
		var process = new Process (command, args);
		var buffer = new BytesOutput ();
		
		if (waitForOutput) {
			
			var waiting = true;
			
			while (waiting) {
				
				try  {
					
					var current = process.stdout.readAll (1024);
					buffer.write (current);
					
					if (current.length == 0) {
						
						waiting = false;
						
					}
					
				} catch (e:Eof) {
					
					waiting = false;
					
				}
				
			}
			
			result = process.exitCode ();
			process.close();
			
			if (result == 0) {
				
				output = buffer.getBytes ().toString ();
				
				if (output == "") {
					
					output = process.stderr.readAll ().toString ();
					
					/*if (error != "") {
						
						LogHelper.error (error);
						
					}*/
					
				}
				
			}
			
		}
		
		if (oldPath != "") {
			
			Sys.setCwd (oldPath);
			
		}
		
		return output;
		
	}
	
	
}