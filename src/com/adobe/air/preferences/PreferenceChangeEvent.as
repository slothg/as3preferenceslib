package com.adobe.air.preferences
{
	import flash.events.Event;
	
	public class PreferenceChangeEvent extends Event
	{
		public static const PREFERENCE_CHANGED_EVENT:String = "preferenceChangedEvent";

		public static const ADD_EDIT_ACTION: String = 'add_edit';
		public static const DELETE_ACTION: String = 'delete';

		public var action: String = null;

		public var name: String = null;
		public var oldValue:* = null;
		public var newValue:* = null;

		public function PreferenceChangeEvent(action: String = null, name: String = null, oldValue: * = null, newValue: * = null) 
		{
			super(PREFERENCE_CHANGED_EVENT);
			this.name = name;
			this.oldValue = oldValue;
			this.newValue = newValue;
			this.action = action;
		}
	}
}