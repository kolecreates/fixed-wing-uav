/*
  Adapted from:
  https://github.com/ozzmaker/BerryIMU/blob/master/python-pressure-sensor-BMP280-BMP388/bmp388.py
  https://github.com/MartinL1/BMP388_DEV/blob/master/BMP388_DEV.h
  https://github.com/ozzmaker/BerryIMU/blob/master/ESP8266-BerryIMU/BerryIMU_ESP8266_Graph_Temperature/bmp180.cpp
*/

#include <bmp388.h>

void bmp388_write_byte(uint8_t subAddress, uint8_t data)
{
  Wire.beginTransmission(BMP388_IC2_ADDR);
  Wire.write(subAddress);
  Wire.write(data);
  Wire.endTransmission();
}

uint8_t bmp388_read_byte(uint8_t subAddress)
{
  uint8_t data = 0x00;
  Wire.beginTransmission(BMP388_IC2_ADDR);
  Wire.write(subAddress);
  Wire.endTransmission(false);
  Wire.requestFrom((uint8_t)BMP388_IC2_ADDR, (uint8_t)1);
  data = Wire.read();

  return data;
}

void bmp388_read_bytes(uint8_t subAddress, uint8_t* data, uint16_t count)
{
  Wire.beginTransmission(BMP388_IC2_ADDR);
	Wire.write(subAddress);
	Wire.endTransmission(false);
	uint8_t i = 0;
	Wire.requestFrom((uint8_t)BMP388_IC2_ADDR, (uint8_t)count);
	while (Wire.available())
	{
		data[i++] = Wire.read();
	}
}


void bmp388_init()
{
  bmp388_write_byte(BMP388_REG_ADD_CMD, BMP388_REG_VAL_SOFT_RESET);

  bmp388_write_byte(BMP388_REG_ADD_PWR_CTRL, BMP388_REG_VAL_PRESS_EN | BMP388_REG_VAL_TEMP_EN | BMP388_REG_VAL_NORMAL_MODE);

  bmp388_read_bytes(BMP388_REG_ADD_CALIB_PARAMS, (uint8_t*)&bmp388_params, sizeof(bmp388_params));

  // Calculate the floating point parameters
  bmp388_float_params.T1 = (float)bmp388_params.T1 / powf(2.0f, -8.0f);
  bmp388_float_params.T2 = (float)bmp388_params.T2 / powf(2.0f, 30.0f);
  bmp388_float_params.T3 = (float)bmp388_params.T3 / powf(2.0f, 48.0f);
  bmp388_float_params.P1 = ((float)bmp388_params.P1 - powf(2.0f, 14.0f)) / powf(2.0f, 20.0f);
  bmp388_float_params.P2 = ((float)bmp388_params.P2 - powf(2.0f, 14.0f)) / powf(2.0f, 29.0f);
  bmp388_float_params.P3 = (float)bmp388_params.P3 / powf(2.0f, 32.0f);
  bmp388_float_params.P4 = (float)bmp388_params.P4 / powf(2.0f, 37.0f);
  bmp388_float_params.P5 = (float)bmp388_params.P5 / powf(2.0f, -3.0f);
  bmp388_float_params.P6 = (float)bmp388_params.P6 / powf(2.0f, 6.0f);
  bmp388_float_params.P7 = (float)bmp388_params.P7 / powf(2.0f, 8.0f);
  bmp388_float_params.P8 = (float)bmp388_params.P8 / powf(2.0f, 15.0f);
  bmp388_float_params.P9 = (float)bmp388_params.P9 / powf(2.0f, 48.0f);
  bmp388_float_params.P10 = (float)bmp388_params.P10 / powf(2.0f, 48.0f);
  bmp388_float_params.P11 = (float)bmp388_params.P11 / powf(2.0f, 65.0f);
}

uint8_t bmp388_get_measurements(volatile float &temperature, volatile float &pressure, volatile float &altitude)
{
  uint8_t data[6];                                                  // Create a data buffer
	bmp388_read_bytes(BMP388_REG_ADD_PRESS_XLSB, &data[0], 6);             	  						// Read the temperature and pressure data
	int32_t adcTemp = (int32_t)data[5] << 16 | (int32_t)data[4] << 8 | (int32_t)data[3];  // Copy the temperature and pressure data into the adc variables
	int32_t adcPres = (int32_t)data[2] << 16 | (int32_t)data[1] << 8 | (int32_t)data[0];
	temperature = bmp388_compensate_temp((float)adcTemp);   					// Temperature compensation (function from BMP388 datasheet)
	pressure = bmp388_compensate_press((float)adcPres, temperature); 	// Pressure compensation (function from BMP388 datasheet)
	pressure /= 100.0f;
  altitude = ((float)powf(1013.23f / pressure, 0.190223f) - 1.0f) * (temperature + 273.15f) / 0.0065f; // Calculate the altitude in metres
  return 1;
}

float bmp388_compensate_temp(float uncomp_temp)
{
	float partial_data1 = uncomp_temp - bmp388_float_params.T1;
	float partial_data2 = partial_data1 * bmp388_float_params.T2;
	return partial_data2 + partial_data1 * partial_data1 * bmp388_float_params.T3;
}

float bmp388_compensate_press(float uncomp_press, float t_lin)
{
	float partial_data1 = bmp388_float_params.P6 * t_lin;
	float partial_data2 = bmp388_float_params.P7 * t_lin * t_lin;
	float partial_data3 = bmp388_float_params.P8 * t_lin * t_lin * t_lin;
	float partial_out1 = bmp388_float_params.P5 + partial_data1 + partial_data2 + partial_data3;
	partial_data1 = bmp388_float_params.P2 * t_lin;
	partial_data2 = bmp388_float_params.P3 * t_lin * t_lin;
	partial_data3 = bmp388_float_params.P4 * t_lin * t_lin * t_lin;
	float partial_out2 = uncomp_press * (bmp388_float_params.P1 +
		partial_data1 + partial_data2 + partial_data3);
	partial_data1 = uncomp_press * uncomp_press;
	partial_data2 = bmp388_float_params.P9 + bmp388_float_params.P10 * t_lin;
	partial_data3 = partial_data1 * partial_data2;
	float partial_data4 = partial_data3 + uncomp_press * uncomp_press * uncomp_press * bmp388_float_params.P11;
	return partial_out1 + partial_out2 + partial_data4;
}
