const {
  light,
  forcePowerSource,
  electricityMeter,
  ota
} = require('zigbee-herdsman-converters/lib/modernExtend');
// Add the lines below

function sengledLight(args) {
  return light({effect: false, powerOnBehavior: false, ...args});
}

const definition = {
  zigbeeModel: ['E11-G14'],
  model: 'E11-G14',
  vendor: 'Sengled',
  description: 'Element classic (A19)',
  extend: [
      forcePowerSource({powerSource: 'Mains (single phase)'}),
      sengledLight(),
      electricityMeter({cluster: 'metering'}),
      ota(),
  ],
};

module.exports = definition;
