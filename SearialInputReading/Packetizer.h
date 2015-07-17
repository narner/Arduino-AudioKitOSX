/*//-------------------------------------------------------------------------------
*  Packetizer.h
*
*  Header file for Packetizer
*  
*  written by: Ingo Randolf - 2014
*
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Lesser General Public
*  License as published by the Free Software Foundation; either
*  version 2.1 of the License, or (at your option) any later version.
//-------------------------------------------------------------------------------*/

// ensure this library description is only included once
#ifndef Packetizer_h
#define Packetizer_h


#include <inttypes.h>
#include <stdio.h> // for size_t
#include <stdlib.h>


#ifdef ARDUINO

// include arduino stuff
#include "WString.h"

#if ARDUINO >= 100
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#else

// not arduino
#include <string>
typedef std::string String;

#endif


enum packetizer_errors
{
  pz_noErr = 0,
  pz_noBuffer,
  pz_bufferSize
};



// library interface description
class Packetizer
{
public:
  Packetizer();
  Packetizer(size_t);  
  ~Packetizer();
  
  
  // buffer
  uint8_t init(size_t);
  uint8_t setBufferSize(size_t);  
  size_t getBufferSize() { return m_bufferSize; };
  uint8_t* getBuffer() { return m_buffer; };
  
  // append data
  uint8_t appendData(int);
  uint8_t appendData(long);
  uint8_t appendData(String);
  uint8_t appendData(uint8_t);
  uint8_t appendData(uint8_t*, size_t);
  
  
  // start condition
  uint8_t setStartCondition(int);
  uint8_t setStartCondition(long);
  uint8_t setStartCondition(String);
  uint8_t setStartCondition(uint8_t*, size_t);
  uint8_t* getStartCondition() { return m_startCondition; };
  size_t getStartConditionSize() { return m_startConditionSize; };  
  bool isStartCondition() { return m_startConditionSize > 0; };
  
  // end condition
  uint8_t setEndCondition(int);
  uint8_t setEndCondition(long);
  uint8_t setEndCondition(String);
  uint8_t setEndCondition(uint8_t*, size_t);
  uint8_t* getEndCondition() { return m_endCondition; };
  size_t getEndConditionSize() { return m_endConditionSize; };  
  bool isEndCondition() { return m_endConditionSize > 0; };
  
#ifdef ARDUINO
  void sendStartCondition(Print& _print);
  void sendEndCondition(Print& _print);
#endif
    
  // user callbacks
  void onPacketStart( void (*)(void) );
  void onPacket( void (*)(uint8_t*, size_t) );
  void onOverflow( void (*)(uint8_t*, size_t) );


private:
  void initVars();
  void freeBuffer(uint8_t**, size_t*);
  uint8_t allocateBuffer(uint8_t**, size_t*, size_t);
  void resetBuffer();
  
  // buffer
  uint8_t*   m_buffer;
  size_t   m_bufferSize;
  
  size_t   m_index; // current index for writing
  bool   m_startFound;


  // start condition
  uint8_t*  m_startCondition;
  size_t  m_startConditionSize;
  size_t  m_startIndex;
  
  // end condition
  uint8_t*  m_endCondition;
  size_t  m_endConditionSize;
  size_t  m_endIndex;
  
  // callbacks
  void (*user_onStart)(void);
  void (*user_onPacket)(uint8_t*, size_t);
  void (*user_onOverflow)(uint8_t*, size_t);

};

#endif

