/*//-------------------------------------------------------------------------------
*	Packetizer.cpp
*
*	Packetizer to analyze data for start and end condition
*	
*	written by: Ingo Randolf - 2014
*
*
*	This library is free software; you can redistribute it and/or
*	modify it under the terms of the GNU Lesser General Public
*	License as published by the Free Software Foundation; either
*	version 2.1 of the License, or (at your option) any later version.
//-------------------------------------------------------------------------------*/


#include "Packetizer.h"


//-------------------------------------------------------------------------------
// Constructor //////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
Packetizer::Packetizer()
{
	initVars();
}

Packetizer::Packetizer(size_t _size)
{
	initVars();
	init(_size);
}


Packetizer::~Packetizer()
{
	freeBuffer(&m_buffer, &m_bufferSize);
	freeBuffer(&m_startCondition, &m_startConditionSize);
	freeBuffer(&m_endCondition, &m_endConditionSize);
}


//-------------------------------------------------------------------------------
// Public Methods ///////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------

uint8_t Packetizer::init(size_t _size)
{
	return setBufferSize(_size);
}

uint8_t Packetizer::setBufferSize(size_t _size)
{
	// free buffer
	freeBuffer(&m_buffer, &m_bufferSize);
	
	// allocate buffer
	uint8_t result = allocateBuffer(&m_buffer, &m_bufferSize, _size);

	// reset things, erase buffer
	resetBuffer();
	
	return result;
}


/*
*	append data
*/
uint8_t Packetizer::appendData(int _data)
{
	return appendData((uint8_t*)&_data, sizeof(int));
}

uint8_t Packetizer::appendData(long _data)
{
	return appendData((uint8_t*)&_data, sizeof(long));
}

uint8_t Packetizer::appendData(String _data)
{
#ifdef __RFduino__
	// Stupidly, RFDuino's copy of String uses cstr() instead of c_str()
	return appendData((uint8_t*)_data.cstr(), (size_t)_data.length());
#else
	return appendData((uint8_t*)_data.c_str(), (size_t)_data.length());
#endif
}

// append data
uint8_t Packetizer::appendData(uint8_t* _buffer, size_t _bufferSize)
{
	if (m_buffer == 0) return pz_noBuffer;
	if (_buffer == 0) return pz_noBuffer;
	if (_bufferSize == 0) return pz_bufferSize;
	
	
	unsigned int i;
	for (i=0; i<_bufferSize; i++)
	{
		appendData(_buffer[i]);
	}
	
	return pz_noErr;
}


// append one byte and test conditions
uint8_t Packetizer::appendData(uint8_t _c)
{
	// safety
	if (m_buffer == 0) return pz_noBuffer;
	
	if (m_startConditionSize > 0)
	{
		// search for start...
		if (_c != m_startCondition[m_startIndex])
			m_startIndex = 0;
			
		if (_c == m_startCondition[m_startIndex])
		{
			if(++m_startIndex >= m_startConditionSize)
			{
				// startcondition found
				// we always start at index 0
				m_index = 0;
				m_endIndex = 0;
				m_startIndex = 0;				
				m_startFound = true;
				
				if (user_onStart)
				{
					user_onStart();
				}
				
				// dont add caracter to buffer
				return pz_noErr;
			}
		}
		
		
		if (!m_startFound) return pz_noErr;
	}
	

	// add data to our buffer
	m_buffer[m_index] = _c;
	
	
	//------------------------------------------------
	// start was found or no startcondition was set
	
	if (m_endConditionSize > 0)
	{	
		// look for endcondition...		
		if (_c != m_endCondition[m_endIndex])
			m_endIndex = 0;
		
		
		if (_c == m_endCondition[m_endIndex])
		{
			if(++m_endIndex >= m_endConditionSize)
			{
				// we found an end... call user-method
				if (user_onPacket)
				{
					size_t len = 0;
					
					// calculate len only if it will be >0
					if ( m_index >= m_endConditionSize)
					{
						len = m_index + 1 - m_endConditionSize;
					}
					
					//call user method
					user_onPacket(m_buffer, len);
				}
				
				// reset index
				m_index = 0;
				m_endIndex = 0;
				m_startIndex = 0;
				m_startFound = false;
			
				return pz_noErr;
			}
		}
	}
	

	// increment writing index
	if (++m_index >= m_bufferSize)
	{
		// reset index	
		m_index = 0;
		
		//call overflow...
		if (user_onOverflow)
		{
			user_onOverflow(m_buffer, m_bufferSize);
		}
	}
	
	return pz_noErr;	
}


/*
*	set startcondition
*/
uint8_t Packetizer::setStartCondition(int _data)
{
	return setStartCondition((uint8_t*)&_data, sizeof(int));
}

uint8_t Packetizer::setStartCondition(long _data)
{
	return setStartCondition((uint8_t*)&_data, sizeof(long));
}

uint8_t Packetizer::setStartCondition(String _data)
{
#ifdef __RFduino__
	// Stupidly, RFDuino's copy of String uses cstr() instead of c_str()
	return setStartCondition((uint8_t*)_data.cstr(), (size_t)_data.length());
#else
	return setStartCondition((uint8_t*)_data.c_str(), (size_t)_data.length());
#endif
}

uint8_t Packetizer::setStartCondition(uint8_t* _buffer, size_t _bufferSize)
{
	// free buffer
	freeBuffer(&m_startCondition, &m_startConditionSize);
	
	// reset
	m_startIndex = 0;
	m_startFound = false;
	
	// safety
	if (_buffer == 0) return pz_noErr;
	if (_bufferSize == 0) return pz_noErr;

	// allocate buffer
	uint8_t result = allocateBuffer(&m_startCondition, &m_startConditionSize, _bufferSize);	
	if (result != pz_noErr)
	{
		return result;
	}
	
	// copy bytes
	memcpy(m_startCondition, _buffer, _bufferSize);
	
	return pz_noErr;
}


/*
*	set endcondition
*/
uint8_t Packetizer::setEndCondition(int _data)
{
	return setEndCondition((uint8_t*)&_data, sizeof(int));
}

uint8_t Packetizer::setEndCondition(long _data)
{
	return setEndCondition((uint8_t*)&_data, sizeof(long));
}

uint8_t Packetizer::setEndCondition(String _data)
{
#ifdef __RFduino__
	// Stupidly, RFDuino's copy of String uses cstr() instead of c_str()
	return setEndCondition((uint8_t*)_data.cstr(), (size_t)_data.length());
#else
	return setEndCondition((uint8_t*)_data.c_str(), (size_t)_data.length());
#endif
}

uint8_t Packetizer::setEndCondition(uint8_t* _buffer, size_t _bufferSize)
{
	// free end condition
	freeBuffer(&m_endCondition, &m_endConditionSize);
	// reset
	m_endIndex = 0;
	
	// safety
	if (_buffer == 0) return pz_noErr;
	if (_bufferSize == 0) return pz_noErr;
	
	
	// allocate buffer
	uint8_t result = allocateBuffer(&m_endCondition, &m_endConditionSize, _bufferSize);	
	if (result != pz_noErr)
	{
		return result;
	}
	
	// copy bytes
	memcpy(m_endCondition, _buffer, _bufferSize);

	return pz_noErr;
}


//-------------------------------------------------------------------------------
// send start and end condition
//-------------------------------------------------------------------------------
#ifdef ARDUINO
void Packetizer::sendStartCondition(Print& _print)
{
    if (m_startConditionSize > 0) {
        _print.write(m_startCondition, m_startConditionSize);
    }
}

void Packetizer::sendEndCondition(Print& _print)
{
    if (m_endConditionSize > 0) {
        _print.write(m_endCondition, m_endConditionSize);
    }
}
#endif


//-------------------------------------------------------------------------------
// Callback functions
//-------------------------------------------------------------------------------
void Packetizer::onPacketStart( void (*function)(void) )
{
	user_onStart = function;
}

void Packetizer::onPacket( void (*function)(uint8_t*, size_t) )
{
	user_onPacket = function;
}

void Packetizer::onOverflow( void (*function)(uint8_t*, size_t) )
{
	user_onOverflow = function;
}


//-------------------------------------------------------------------------------
// Private Methods //////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------
void Packetizer::initVars()
{
	m_buffer = 0;
	m_bufferSize = 0;
	m_index = 0;
	m_startFound = false;
	m_startCondition = 0;
	m_startConditionSize = 0;
	m_startIndex = 0;
	m_endCondition = 0;
	m_endConditionSize = 0;
	m_endIndex = 0;
	
	user_onStart = 0;
	user_onPacket = 0;
	user_onOverflow = 0;
}


void Packetizer::freeBuffer(uint8_t** _buffer, size_t* _bufferSize)
{
	// free buffer if allocated
	if (*_buffer != 0) {
		free(*_buffer);		
	}
	
	*_buffer = 0;
	*_bufferSize = 0;
}


uint8_t Packetizer::allocateBuffer(uint8_t** _buffer, size_t* _bufferSize, size_t _size)
{
	// safety
	if (_size == 0) return pz_bufferSize;
		
	
	// allocate buffer
	*_buffer = (uint8_t*)malloc(_size);
  
  	// test
	if (*_buffer == 0) {
		return pz_noBuffer;
	}
	
	// set size
	*_bufferSize = _size;
	
	return pz_noErr;
}


void Packetizer::resetBuffer()
{
	m_index = 0;	
	m_startIndex = 0;
	m_endIndex = 0;	
	m_startFound = false;
	
	if (m_buffer == 0) return;
	if (m_bufferSize == 0) return;
	
	// clear buffer
	memset(m_buffer, 0, m_bufferSize);	
}
