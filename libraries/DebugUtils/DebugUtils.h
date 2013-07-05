/*
DebugUtils.h - Simple debugging utilities.
Copyright (C) 2011 Fabio Varesano <fabio at varesano dot net>

Ideas taken from:
http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1271517197

This program is free software: you can redistribute it and/or modify
it under the terms of the version 3 GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

/*
2012-02-21, This version adapated by Alan Holding, MDDA, manchesterdda.com to allow printing of debug messages via Waspmote's USB serial monitor. Big thanks, Fabio. You saved my bacon!
*/

#ifndef DEBUGUTILS_H
#define DEBUGUTILS_H
#endif

#ifdef DEBUG
#define DEBUG_PRINT(str) \
	XBee.println(" "); \
    XBee.print(millis()); \
    XBee.print(": "); \
    XBee.print(__PRETTY_FUNCTION__); \
    XBee.print(" "); \
    XBee.print(__FILE__); \
    XBee.print(":"); \
    XBee.print(__LINE__); \
    XBee.print(" "); \
    XBee.println(str);
#define DEBUG_PRINT_DEC(str) \
	XBee.println(" "); \
    XBee.print(millis()); \
    XBee.print(": "); \
    XBee.print(__PRETTY_FUNCTION__); \
    XBee.print(" "); \
    XBee.print(__FILE__); \
    XBee.print(":"); \
    XBee.print(__LINE__); \
    XBee.print(" "); \
    XBee.println(str, DEC);
#define DEBUG_PRINT_HEX(str) \
	XBee.println(" "); \
    XBee.print(millis()); \
    XBee.print(": "); \
    XBee.print(__PRETTY_FUNCTION__); \
    XBee.print(" "); \
    XBee.print(__FILE__); \
    XBee.print(":"); \
    XBee.print(__LINE__); \
    XBee.print(" "); \
    XBee.println(str, HEX);
//  Messages. (Helps avoid filling up the memory, buffer overflows and such and that. Is that my tea you're drinking?)
#define MSG_SETUP          			"Set up"
#define MSG_ENTERING_SLEEP          "Sleep"
#define MSG_STARTING_LOOP          	"Loop"
#define MSG_REBOOTING				"Reboot"
#define MSG_PROBLEM                 "Problem"
#define MSG_DATA_FILE_NOT_FOUND     "FNF"
#define MSG_DIR_CD_ERROR            "!CD data dir"
#define MSG_DATA_DIR_NOT_FOUND      "!Data dir"
#define MSG_SDCARD_CARD_NOT_PRESENT "!SD card"
#define MSG_SDCARD_NOT_RESPONDING   "!SD"
#define MSG_APPENDED_OK             "Append"
#define MSG_EOL_OK                  "EOL"
#define MSG_WRITE_ERROR             "!Write"
#define MSG_CREATE_FILE_OK			"File created"
#define MSG_CREATE_FILE_ERROR		"!File created"
#define MSG_FILE_EXISTS				"File exists"
#define MSG_ATTEMPTING_TO_WRITE		"SD write attempt"
#define MSG_RESETTING_VARIABLES		"Var reset"
#define MSG_CHECKING_ZIGBEE			"ZB check"
#define MSG_CHECKING_SD				"SD check"
#define MSG_SD_NOT_OK				"!SD"
#define MSG_ZB_NOT_OK				"!ZB"
#define MSG_SD_OK					"SD OK"
#define MSG_ZB_OK					"ZB OK"
#define MSG_CONSTRUCTING_DATA_FRAME	"Data frame"
#define MSG_ATTEMPTING_TO_SEND		"ZB send attempt"
#define MSG_ZB_TRANSMIT_ERROR		"!ZB transmit"
#define MSG_ASSOCIATED				"ZB associated"
#define MSG_ASSOCIATED_AND_DATA_SENT "ZB sent"
#define MSG_ZB_TIMED_OUT			"ZB timeout"
#define MSG_DATA_ADDED_TO_SD		"SD data added no ZB send"
#define MSG_READY_TO_SEND			"SD data added ready for ZB send"
#define MSG_FREE_MEMORY				"Free:"
#define MSG_HERE					"HERE"
#else
#define DEBUG_PRINT(str)
#define DEBUG_PRINT_DEC(str)
#define DEBUG_PRINT_HEX(str)
#endif
