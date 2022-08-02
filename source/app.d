import dlangui;

mixin APP_ENTRY_POINT;

/**
role: app_2
password: e5uqi2fd
*/

extern(C) int UIAppMain(string[] args){
	import dpq2;
	import screens.screen_0.process;
	Connection toAgriDB;
	screen_0(toAgriDB);

	// run message loop
	return Platform.instance.enterMessageLoop();
}
