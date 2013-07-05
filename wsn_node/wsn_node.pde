/*

wsn_node.pde
2013-06-04, Alan Holding, MDDA, manchesterdda.com.
2013-07-05, Cleaned up version for GitHub repository.

Gets raw voltage readings from sensors attached to a Gas Sensor Board attached to a Waspmote v1.1 microcontroller.
Sends the readings to a ZigBee network coordinator via a ZigBee radio attached to the Waspmote.
Sleeps for approximately thirty minutes and repeats.

Data sent per ZigBee frame transmission:
* device_id, e.g. WASP0001
* sensor_id, e.g. 1
* reading, e.g. 2.432154
* minreading, e.g. 1.432154
* maxreading, e.g. 3.232154
* counter, e.g. 23

IDs used for sensors / peripherals on the Waspmote:
* 999 Battery
* 1 Temperature
* 2 Humidity
* 3 Carbon monoxide
* 4 Carbon dioxide
* 5 Nitrogen dioxide

This program is free software: you can redistribute it and/or modify it under the terms of the version 3 GNU General Public License as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Defines for this device.
TODO: Move to EEPROM.
*/
#define DEVICE_ID "WASP0001"

/*
Set up variables for readings from sensors attached to the Waspmote.
*/

//  Battery
float bat = 0.0;

//  Temperature
float tmp = 0.0;
float tmpmin = 255.0;
float tmpmax = 0.0;

//  Humidity
float hum = 0.0;
float hummin = 255.0;
float hummax = 0.0;

//  Carbon monoxide
float co = 0.0;
float comin = 255.0;
float comax = 0.0;

//  Carbon dioxide
float co2 = 0.0;
float co2min = 255.0;
float co2max = 0.0;

//  Nitrogen Dioxide
float no2 = 0.0;
float no2min = 255.0;
float no2max = 0.0;

/*
Gains and resitance values for sensors that need them on this Waspmote.
NOTE: These values are based on sensor calibration runs and are specific to each Waspmote / Gas Board "unit". The values you use may vary.
*/
int    MDDA_CO_GAIN = 1;
float  MDDA_CO_RESISTANCE = 90.0;
int    MDDA_CO2_GAIN = 10;
int    MDDA_NO2_GAIN = 2;
float  MDDA_NO2_RESISTANCE = 33.0;

/*
Comment out the line below if you do NOT want debug messages printing via the serial monitor when the Waspmote is connected to a computer via USB.
*/
#define DEBUG
/*
DebugUtils.h is a separate file in this repository.
NOTE: The file contains defined "debug" strings and other definitions. Most of the defines were used during development of this software and are not (currently) used. Though that may change!
*/
#include <DebugUtils.h>

/*
WSNUtils.h is a separate file in this repository.
NOTE: The file contains some defined strings that made debugging this software more a bit easier and that.
*/
#include <WSNUtils.h>

/*
ZigBee radio network settings.
NOTE: You will need to change these to the High / Low addresses of your ZigBee radios. These are hard coded here for convenience / demonstration, but the Waspmote API can query the ZigBee for its address using the xbeeZB.getOwnMacLow() and xbeeZB.getOwnMacHight() functions.
*/
#define ZB_MAC_OF_RECEIVING_ZIGBEE "0013A200406A022F" //  ZigBee co-ordinator (Arduibee)
#define ZB_MAC_OF_SENDING_ZIGBEE "0013A200406A0245"  //  WASP0001 (This Waspmote)

/*
Variable to hold the data that will be sent via ZigBee.
*/
char data_frame[200];

/*
The counter is used to spot any "gaps" in sending data.
*/
uint16_t counter = 0;

/*
"Placeholder" variable to note the current sensor being read / reported on.
*/
uint16_t sensor_id = 0;

/*
*****
SETUP
*****
The setup() function is run when the Waspmote is turned on, resets or wakes from hibernation.
*/
void setup() {

  /*
  Allow the Waspmote to talk to the real time clock.
  */
  RTC.ON();

  /*
  Set up the serial monitor over USB so you can see debug messages.
  */
  USB.begin();

} //  End of setup()

/*
****
LOOP
****
The loop() function is run until the power runs out or something else (eek!) goes wrong.
*/
void loop() {

  /*
  DEBUG_PRINT() and DEBUG_PRINT_DEC() used later are functions which print out debug messages over the serial monitor. See DebugUtils.h and WSNUtils.h.
  */
  DEBUG_PRINT(MSG_ENTERING_SLEEP);

  /*
  Put the Waspmote into deep sleep mode for twenty five minutes.
  NOTE: You should check that the watch battery in the Wasmpmote is fresh, otherwise the watch "alarm" will never trigger and wake up the Waspmote from its sleep.
  */
  PWR.deepSleep("00:00:25:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  /*
  Did we just wake up from deep sleep?
  */
  if(intFlag & RTC_INT) {

    /*
    We have woken up from a deep sleep. At this point everything except the Waspmote board is powered off, so we'll have to power things up as we need them…
    */

    /*
    Allow the Waspmote to talk to the real time clock (again), clear the alarm on the real time clock and ask the clock for the time.
    */
    RTC.ON();
    RTC.clearAlarmFlag();
    RTC.getTime();

    /*
    Set up the serial monitor over USB so you can see debug messages.
    */
    USB.begin();
    DEBUG_PRINT(MSG_STARTING_LOOP);
    DEBUG_PRINT(MSG_FREE_MEMORY);
    DEBUG_PRINT_DEC(freeMemory());

    /*
    Reboot the Waspmote if this is the hundreth cycle through the loop().
    NOTE: This is probably not needed. Just the author being paranoid about memory leaks.
    */
    if (counter == 100) {
      DEBUG_PRINT(MSG_REBOOTING);
      delay(250);
      PWR.reboot();
    }

    /*
    Power up the attached Gas Sensor Board.
    */
    SensorGas.setBoardMode(SENS_ON);
    delay(50);

    /*
    Power up and configure the carbon monoxide sensor.
    NOTE: This sensor is powered up as soon as the Gas Sensor Board is switched on. See earlier in the code for the gain and resistance values.
    */
    SensorGas.configureSensor(SENS_SOCKET3B, MDDA_CO_GAIN, MDDA_CO_RESISTANCE);

    /*
    Configure and turn on the nitrogen dioxide sensor, then wait 4m 30secs to give the sensor time to settle before taking a reading.
    TODO: Clarify the "on time" required for the nitrogen dioxide sensor.
    TODO: Change this software to only use the nitrogen dioxide sensor every X runs through the loop().
    */
    SensorGas.configureSensor(SENS_SOCKET2B, MDDA_NO2_GAIN, MDDA_NO2_RESISTANCE);
    SensorGas.setSensorMode(SENS_ON, SENS_SOCKET2B);
    delay(270000);  //  4m 30s

    /*
    270 seconds later…
    */

    /*
    Power up and initialise the ZigBee radio attached to the Waspmote.
    */
    xbeeZB.init(ZIGBEE,FREQ2_4G,PRO);
    xbeeZB.ON();

    /*
    Power up and configure the carbon dioxide sensor
    */
    SensorGas.configureSensor(SENS_CO2, MDDA_CO2_GAIN);
    SensorGas.setSensorMode(SENS_ON, SENS_CO2);

    /*
    Delay 29 seconds to allow ZigBee radio to associate with the ZigBee network.
    NOTE: See http://www.libelium.com/forum/viewtopic.php?f=17&t=7641&hilit=associationIndication
    TODO: Put back the getAssociationIndication() function from earlier versions.
    */
    delay(29000);

    /*
    Set up some ZigBee encryption stuff.
    */
    xbeeZB.setAPSencryption(XBEE_ON);

    /*
    Call the function which takes the readings from the sensors.
    */
    readSensors();

    /*
    Increment the loop counter.
    */
    counter++;

    /*
    Prepare ZigBee data frame for each sensor value, then attempt to send that data frame to the receiving ZigBee radio (in this case, the ZigBee radio on the Arduibee). The WSN_constructDataFrame() and WSN_attemptToSendDataFrameViaZigBee() defined further down in thi code are used to do the preparing and sending.
    TODO: This is very non-DRY and should be improved, don't ya think?
    */

    //  Battery
    WSN_constructDataFrame(999, bat, bat, bat);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2500);

    //  Temperature
    WSN_constructDataFrame(1, tmp, tmpmin, tmpmax);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2500);

    //  Humidity
    WSN_constructDataFrame(2, hum, hummin, hummax);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2500);

    //  Carbon monoxide
    WSN_constructDataFrame(3, co, comin, comax);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2500);

    //  Carbon dioxide
    WSN_constructDataFrame(4, co2, co2min, co2max);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2000);

    //  Nitrogen dioxide
    WSN_constructDataFrame(5, no2, no2min, no2max);
    WSN_attemptToSendDataFrameViaZigBee();
    delay(2500);

  } //  End of deep sleep check

} //  End of loop()

/*
***************
OTHER FUNCTIONS
***************
*/

/*
Creates a "string" stored in data_frame which will be sent via the ZigBee radio.
int sensor_id, e.g. 1
float sensor_reading, e.g. 12.345
float minimum_reading, e.g. 10.432,
float maximum_reading, e.g. 12.456
*/
void WSN_constructDataFrame(int sensor_id, float sensor_reading, float minimum_reading, float maximum_reading) {

  DEBUG_PRINT(MSG_CONSTRUCTING_DATA_FRAME);

  /*
  Convert floats to strings for sprintf %s. Fun!
  */
  char the_reading[8];
  char min_reading[8];
  char max_reading[8];
  Utils.float2String(sensor_reading, the_reading, 4);
  Utils.float2String(minimum_reading, min_reading, 4);
  Utils.float2String(maximum_reading, max_reading, 4);

  /*
  Create the "string"
  */
  sprintf(
    data_frame,
    "%s,%d,%s,%s,%s,%d",
    DEVICE_ID,
    sensor_id,
    the_reading,
    min_reading,
    max_reading,
    counter
  );

  DEBUG_PRINT(data_frame);
} //  End of WSN_constructDataFrame()


/*
Attempts to send the data in data_frame over the ZigBee radio.
*/
void WSN_attemptToSendDataFrameViaZigBee() {

  packetXBee * paq_sent;                //  pointer for ZigBee data packet

  /*
  This stuff is to check if the attached ZigBee radio has connected to the ZigBee network.
  */
  uint8_t attempt = 0;                  //  counter for zigbee network association attempts
  uint8_t association_delay = 250;      //  milliseconds
  uint8_t max_attempts = (30 * 1000) / association_delay;

  while(attempt < max_attempts) {
    xbeeZB.getAssociationIndication();
    if (xbeeZB.associationIndication == 0) {

      /*
      If we get here the attached ZigBee radio has associated with the ZigBee network.
      */
      delay(100);
      attempt = max_attempts;

      /*
      Prepare ZigBee data frame and some associated ZigBee radio configuration stuff.
      */
      paq_sent = (packetXBee*) calloc(1,sizeof(packetXBee));
      paq_sent->mode = UNICAST;
      paq_sent->MY_known = 0;
      paq_sent->packetID = 0x52;
      paq_sent->opt = 0x00;

      xbeeZB.hops = 0;
      xbeeZB.setOriginParams(paq_sent, "3E3F", MY_TYPE);
      //xbeeZB.setOriginParams(paq_sent, ZB_MAC_OF_SENDING_ZIGBEE, MAC_TYPE);
      xbeeZB.setDestinationParams(paq_sent, ZB_MAC_OF_RECEIVING_ZIGBEE, data_frame, MAC_TYPE, DATA_ABSOLUTE);

      /*
Attempt to send the data
*/
      xbeeZB.sendXBee(paq_sent);
      if (xbeeZB.error_TX > 0) {
        DEBUG_PRINT(MSG_ZB_TRANSMIT_ERROR);
        DEBUG_PRINT(xbeeZB.error_TX);
      } else {
        DEBUG_PRINT(MSG_ASSOCIATED_AND_DATA_SENT);
        xbeeZB.writeValues();
      }
    } else {
      /*
      Print association indication value.
      */
      DEBUG_PRINT("ATAI = ");
      DEBUG_PRINT_HEX(xbeeZB.associationIndication);
      delay(association_delay);
    } //  End of if (xbeeZB.associationIndication == 0)
    attempt++;
  } //  End of while(attempt < max_attempts)

  DEBUG_PRINT(MSG_ZB_TIMED_OUT);

  /*
  Free up some memory.
  */
  free(paq_sent);
  paq_sent = NULL;
}

/*
Reads the raw voltage readings from the sensors attached to the Gas Sensor Board.
*/
void readSensors() {
  float no2Vread = 0.0;
  float no2Vsum = 0.0;

  float co2Vread = 0.0;
  float co2Vsum = 0.0;

  float coVread = 0.0;
  float coVsum = 0.0;

  float humVread = 0.0;
  float humVsum = 0.0;

  float tmpVsum = 0.0;
  float tmpVread = 0.0;

  int numReadings = 5;

  for (int i=0; i < numReadings; i++) {

    no2Vread = SensorGas.readValue(SENS_SOCKET2B);
    no2Vsum += no2Vread;
    no2min = getMin(no2min,no2Vread);
    no2max = getMax(no2max,no2Vread);

    co2Vread = SensorGas.readValue(SENS_CO2);
    co2Vsum += co2Vread;
    co2min = getMin(co2min,co2Vread);
    co2max = getMax(co2max,co2Vread);

    coVread = SensorGas.readValue(SENS_SOCKET3B);
    coVsum += coVread;
    comin = getMin(comin,coVread);
    comax = getMax(comax,coVread);

    humVread = SensorGas.readValue(SENS_HUMIDITY);
    humVsum += humVread;
    hummin = getMin(hummin,humVread);
    hummax = getMax(hummax,humVread);

    tmpVread = SensorGas.readValue(SENS_TEMPERATURE);
    tmpVsum += tmpVread;
    tmpmin = getMin(tmpmin,tmpVread);
    tmpmax = getMax(tmpmax,tmpVread);

    delay(2000);
  } // End of for (int i=0; i < numReadings; i++)

  bat = PWR.getBatteryLevel();
  delay(250);

  /*
  Power down the Gas Sensor Board as it's not needed anymore during this loop.
  */
  SensorGas.setBoardMode(SENS_OFF);

  tmp = tmpVsum / (float)numReadings;
  hum = humVsum / (float)numReadings;
  co  = coVsum  / (float)numReadings;
  co2 = co2Vsum / (float)numReadings;
  no2 = no2Vsum / (float)numReadings;
} //  End of readSensors()

/*
Returns minimum value from those supplied.
*/
float getMin(float current, float reading) {
  if (reading <= current) {
   return reading;
  } else {
   return current;
  }
}

/*
Returns maxiumum value from those supplied.
*/
float getMax(float current, float reading) {
  if (reading >= current) {
   return reading;
  } else {
   return current;
  }
}
