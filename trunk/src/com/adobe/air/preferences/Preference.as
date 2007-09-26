package com.adobe.air.preferences
{
	import flash.events.EventDispatcher;
	import flash.filesystem.EncryptedLocalStore;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.*;
	import flash.utils.ByteArray;

	[Event(name=PreferenceChangeEvent.PREFERENCE_CHANGED_EVENT, type="com.adobe.air.notification.PreferenceChangeEvent")]

	public class Preference extends EventDispatcher
	{
		private var _modified: Boolean = false;
		private var _filename: String = null;
		
		private var _data: Object = {};
		
		public function Preference(filename: String = null)
		{
			super();
			registerClassAlias("com.adobe.air.preferences.PreferenceItem",  com.adobe.air.preferences.PreferenceItem);			
			if (filename == null)
			{
				this._filename = "prefs.obj";
			}
		}
		
		public function get modified(): Boolean
		{
			return this._modified;
		}
		
		private static const s_boolean: String = 'Boolean';
		private static const s_int: String = 'int';
		private static const s_uint: String = 'uint';
		private static const s_number: String = 'Number';
		private static const s_bytearray: String = 'ByteArray';

		public function setValue(name: String, value: *, encrypted: Boolean = false): void
		{
			this._modified = this.getValue(name) != value;
			if (this._modified)
			{
				var prefItm: PreferenceItem = new PreferenceItem();
				prefItm.encrypted = encrypted;
				if (encrypted)
				{
					var bytes:ByteArray = new ByteArray();
					if (value is Boolean)
					{
						prefItm.value = s_boolean;
						bytes.writeBoolean(value);
					}
					else if (value is int)
					{
						prefItm.value = s_int;
						bytes.writeByte(value);
					}
					else if (value is uint)
					{
						prefItm.value = s_uint;
						bytes.writeUnsignedInt(value);
					}
					else if (value is Number)
					{
						prefItm.value = s_number;
						bytes.writeDouble(value);
					}
					else if (value is ByteArray)
					{
						prefItm.value = s_bytearray;
						bytes.writeBytes(value);
					}
					else  // all other types including string
					{
						bytes.writeUTFBytes(value);
					}
					EncryptedLocalStore.setItem(name, bytes);
				}
				else
				{
					prefItm.value = value;
				}
				this._data[name] = prefItm;
				this.dispatchEvent(new PreferenceChangeEvent(PreferenceChangeEvent.ADD_EDIT_ACTION));
			}
		}

		public function getValue(name: String): *
		{
			var result: * = null;
			if (this._data[name] != undefined)
			{
				var prefItm: PreferenceItem = PreferenceItem(this._data[name]);
				if (prefItm.encrypted)
				{
					var bytes:ByteArray = EncryptedLocalStore.getItem(name);
					if (prefItm.value == s_boolean)
					{
						result = bytes.readBoolean();
					}
					else if (prefItm.value == s_int)
					{
						result = bytes.readByte();
					}
					else if (prefItm.value == s_uint)
					{
						result = bytes.readUnsignedByte();
					}
					else if (prefItm.value == s_number)
					{
						result = bytes.readDouble();
					}
					else if (prefItm.value == s_bytearray)
					{
						result = new ByteArray();
						bytes.readBytes(result);
					}
					else  // all other types including string
					{
						result = bytes.readUTFBytes(bytes.length);
					}
				}
				else
				{
					result = prefItm.value;
				}
			}
			return result;
		}

		public function deleteValue(name: String): void
		{
			if (this._data[name] != undefined)
			{
				if (PreferenceItem(this._data[name]).encrypted)
				{
					EncryptedLocalStore.removeItem(name);
				}
				delete this._data[name];
				this.dispatchEvent(new PreferenceChangeEvent(PreferenceChangeEvent.DELETE_ACTION));
			}
		}

		public function savePreferences(): void
		{
			var prefsFile: File = File.applicationStorageDirectory.resolvePath(this._filename);
			var fs: FileStream = new FileStream();
			try
			{
				fs.open(prefsFile, FileMode.WRITE);
				fs.writeObject(this._data);
			}
			finally
			{
				fs.close();
			}
		}

		public function readPreferences(): void
		{
			var prefsFile: File = File.applicationStorageDirectory.resolvePath(this._filename);
			if (prefsFile.exists)
			{
				var fs: FileStream = new FileStream();
				try
				{
					fs.open(prefsFile, FileMode.READ);
					this._data = fs.readObject();
				}
				finally
				{
					fs.close();
				}
			}
		}
	}
}