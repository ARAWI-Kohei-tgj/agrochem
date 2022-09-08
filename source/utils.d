module utils;

import std.traits: isUnsigned, isSomeString;
/**
 * int -> string
 **/
 Str integerToHexStr(U, Str= string)(in U num) @system
if(isUnsigned!U && isSomeString!Str){
	import std.array: appender;
	import std.format: formattedWrite;

	auto buf= appender!Str;
	buf.formattedWrite!"%04x"(num);
	return buf.data;
}

ushort hexStrToUshort(in string str) @system{
	import std.format: formattedRead;
	typeof(return) result= void;
	str.dup.formattedRead!"%x"(result);
	return result;
}

/******/
struct SpraySummary{
	import std.datetime: Date;

	ushort sprayId;
	Date dateSpray;
	string sprayType;
	float amountNum;
	string anountUnit;
}
