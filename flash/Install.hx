import Sys.*;
import sys.FileSystem.*;
import sys.io.File.*;
import haxe.io.*;

class Install {
	static var fpDownload(default, never) = switch (systemName()) {
		case "Linux":
			"https://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz";
		case "Mac":
			"https://fpdownload.macromedia.com/pub/flashplayer/updaters/18/flashplayer_18_sa_debug.dmg";
		case "Windows":
			"https://fpdownload.macromedia.com/pub/flashplayer/updaters/18/flashplayer_18_sa_debug.exe";
		case _:
			throw "unsupported system";
	}
	static var mmcfgPath(default, never) = switch (systemName()) {
		case "Linux":
			Path.join([getEnv("HOME"), "mm.cfg"]);
		case "Mac":
			"/Library/Application Support/Macromedia/mm.cfg";
		case "Windows":
			Path.join([getEnv("SYSTEMROOT"), "system32", "Macromed", "Flash", "mm.cfg"]);
		case _:
			throw "unsupported system";
	}
	static var fpTrust(default, never) = switch (systemName()) {
		case "Linux":
			Path.join([getEnv("HOME"), ".macromedia/Flash_Player/#Security/FlashPlayerTrust"]);
		case "Mac":
			"/Library/Application Support/Macromedia/FlashPlayerTrust";
		case "Windows":
			Path.join([getEnv("SYSTEMROOT"), "system32", "Macromed", "Flash", "FlashPlayerTrust"]);
		case _:
			throw "unsupported system";
	}
	static function main() {
		switch (systemName()) {
			case "Linux":
				// Download and unzip flash player
				if (command("wget", [fpDownload]) != 0)
					throw "failed to download flash player";
				if (command("tar", ["-xf", Path.withoutDirectory(fpDownload), "-C", "flash"]) != 0)
					throw "failed to extract flash player";
			case "Mac":
				if (command("brew", ["install", "caskroom/cask/brew-cask"]) != 0)
					throw "failed to brew install caskroom/cask/brew-cask";
				if (command("brew", ["cask", "install", "flash-player-debugger", "--appdir=flash"]) != 0)
					throw "failed to install flash-player-debugger";
			case "Window":
				// Download flash player
				if (command("appveyor", ["DownloadFile", fpDownload, "-FileName", "flash\\flashplayer.exe"]) != 0)
					throw "failed to download flash player";
		}
		

		// Create a configuration file so the trace log is enabled
		createDirectory(Path.directory(mmcfgPath));
		saveContent(mmcfgPath, "ErrorReportingEnable=1\nTraceOutputFileEnable=1");

		// Add the current directory as trusted, so exit() can be used
		createDirectory(fpTrust);
		saveContent(Path.join([fpTrust, "test.cfg"]), getCwd());
	}
}