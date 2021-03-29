/*
  Adapted from:
  https://github.com/ozzmaker/BerryIMU/blob/master/python-pressure-sensor-BMP280-BMP388/bmp388.py
  https://github.com/MartinL1/BMP388_DEV/blob/master/BMP388_DEV.h
  https://github.com/ozzmaker/BerryIMU/blob/master/ESP8266-BerryIMU/BerryIMU_ESP8266_Graph_Temperature/bmp180.cpp
*/

#include <stdint.h>
#include <Arduino.h>
#include <Wire.h>

#ifndef _DEF_BMP388_
#define _DEF_BMP388_

enum {
  BMP388_IC2_ADDR = 0x77,
  BMP388_REG_ADD_CMD = 0x7E,
  BMP388_REG_VAL_SOFT_RESET = 0xB6,
  BMP388_REG_ADD_PWR_CTRL = 0x1B,
  BMP388_REG_VAL_ENABLE_PRESS = 0x01,
  BMP388_REG_VAL_ENABLE_TEMP = 0x02,
  BMP388_REG_VAL_NORMAL_MODE = 0x30,

  BMP388_REG_ADD_CALIB_PARAMS = 0x31,
  BMP388_REG_ADD_PRESS_XLSB = 0x04,
};

struct {
	uint16_t  T1;
	uint16_t  T2;
	int8_t    T3;
	int16_t   P1;
	int16_t   P2;
	int8_t    P3;
	int8_t    P4;
	uint16_t  P5;
	uint16_t  P6;
	int8_t    P7;
	int8_t    P8;
	int16_t   P9;
	int8_t 	  P10;
	int8_t 	  P11;
} __attribute__ ((packed)) bmp388_params;

struct {
  float T1;
  float T2;
  float T3;
  float P1;
  float P2;
  float P3;
  float P4;
  float P5;
  float P6;
  float P7;
  float P8;
  float P9;
  float P10;
  float P11;
} bmp388_float_params;

void bmp388_write_byte(uint8_t subAddress, uint8_t data);
uint8_t bmp388_read_byte(uint8_t subAddress);
void bmp388_read_bytes(uint8_t subAddress, uint8_t* data, uint16_t count);
void bmp388_init();
uint8_t bmp388_get_measurements(volatile float &temperature, volatile float &pressure, volatile float &altitude);
float bmp388_compensate_temp(float uncomp_temp);
float bmp388_compensate_press(float uncomp_press, float t_lin);
#endif
