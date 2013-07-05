# wsn-node

Waspmote sketch for sensor devices on [MDDA](http://manchesterdda.com) Wireless Sensor Network.

* Sleeps for approximately thirty minutes.
* Gets raw voltage readings from sensors attached to a Gas Sensor Board attached to a Waspmote v1.1 microcontroller.
* Sends the readings to a ZigBee network coordinator via a ZigBee radio attached to the Waspmote.
* Repeats

## Background

This software was developed as part of the [Smart IP project](http://www.smart-ip.eu) to support the trial of an on-street Wireless Sensor Network in parts of Manchester, UK.

## Requirements

* [Libelium Waspmote v1.1](http://www.libelium.com/development-v11/)
* [Libelium Waspmote IDE v.02](http://www.libelium.com/development-v11/)
* Libelium Waspmote Gas Sensor Board v1.0
* Various sensors
* ZigBee radio (XBee Pro S2)

## Installation

Clone / download the files to your Waspmote's sketch directory. You can find this directory via _Preferences > Sketchbook location_ in the Waspmote IDE. Be careful not to overwrite your Waspmote's _libraries_ directory. You just want to add the DebugUtils and WSNUtils directories to your libraries directory.

## Preparation / Specificity

The gain and resistance values for some sensors are based on calibration runs specific to each Waspmote / Gas Board "unit". The gain and resistance values you use may (and probably will) vary.

You will need to configure ZigBee radios that you use.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the version 3 GNU General Public License as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

The above applies to the files wsn_node.pde and WSNUtils.h.

DebugUtils.h is copyright © 2011 Fabio Varesano. See the license notice in the DebugUtils.h file.

### Waspmote source code license

As I understand it, Waspmote source code libraries […are released under the LGPL license…](http://www.cooking-hacks.com/index.php/documentation/tutorials/Waspmote). Waspmote is made by [Libelium Comunicaciones Distribuidas S.L.](http://www.libelium.com).



Thanks for reading! Your pal, Al.