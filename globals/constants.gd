extends Node

var OutgoingEvent = {
	"SOUND_ADD": "SOUND:ADD",
	"SOUND_UPDATE": "SOUND:UPDATE",
	"SOUND_REMOVE": "SOUND:REMOVE",
	"SOUND_FETCH": "SOUND:FETCH",
	"SOUND_PLAY": "SOUND:PLAY",
	"SOUND_STOP": "SOUND:STOP",
	"CONFIG_FETCH": "CONFIG:FETCH",
	"CONFIG_UPDATE": "CONFIG:UPDATE",
}

enum LoadingEvents {
	Setup,
	Start,
	FetchInitialInformation
}
