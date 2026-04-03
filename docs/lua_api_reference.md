# Luna2D Audio API Reference

## luna.audio.create_bus(name)
Creates a new audio bus for applying shared volume, pitch, and effects to a group of sources.
- **Parameters**: 
ame (string)
- **Returns**: None

## luna.audio.add_effect(bus_name, effect_id, effect_type)
Adds a real-time DSP effect to the specified bus.
- **Parameters**:
  - us_name (string): The bus to apply the effect to.
  - effect_id (number): A unique identifier for this effect instance.
  - effect_type (string): The type of effect (e.g., "Lowpass", "Reverb").
- **Returns**: None

## luna.audio.remove_effect(bus_name, effect_id)
Removes an effect from the specified bus.
- **Parameters**:
  - us_name (string)
  - effect_id (number)
- **Returns**: None

## luna.audio.set_effect_param(bus_name, effect_id, param_index, value)
Updates a parameter of an active DSP effect.
- **Parameters**:
  - us_name (string)
  - effect_id (number)
  - param_index (number)
  - alue (number)
- **Returns**: None

## luna.audio.play(sound_name, [options])
Plays a sound. 
- **Options**:
  - us: (string) The name of the bus to route this sound through.
  - olume, pitch, loop, ade_in.
