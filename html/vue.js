// ######## configs for ords and apex ########
var url = 'ORDS_URL';
var apex = 'APEX_URL';

var data = { apex: {}, free: { price : {}, options : {} }, pro: { price : {}, options : {} }, enterprise: { price : {}, options : {} } };

var pricing = new Vue({
  el: '#pricing',
  data: { data },
  mounted () {
    console.log("ords: " + url);
    data.apex = { url: apex };
    console.log("apex: " + data.apex.url);
    data.free = { price : {}, options : {} }
    data.pro = { price : {}, options : {} }
    data.enterprise = { price : {}, options : {} }
    getTierPrice('free');
    getTierPrice('pro');
    getTierPrice('enterprise');
    getTierOptions('free');
    getTierOptions('pro');
    getTierOptions('enterprise');
  },
  methods:{
  }
})

function getTierPrice(tier, callback) {
    console.log(tier);
    axios
      .get(url + '/price/' + tier)
      .then(resp => 
            {        
                switch(tier)
                {
                    case 'free':
                        data.free.price = resp.data.items[0];
                        break;
                    case 'pro':
                        data.pro.price = resp.data.items[0];
                        break;
                    case 'enterprise':
                        data.enterprise.price = resp.data.items[0];
                        break;
                    default:
                        console.log('undefined tier ' + tier);
                }
                return callback;
            }
        )
     .catch(error => {
            console.log(error)
        })
     .finally(() => { 
            //console.log(data);
        })
}

function getTierOptions(tier, callback) {
    console.log(tier);
    axios
      .get(url + '/options/' + tier)
      .then(resp => 
            {        
                switch(tier)
                {
                    case 'free':
                        data.free.options = resp.data.items[0];
                        break;
                    case 'pro':
                        data.pro.options = resp.data.items[0];
                        break;
                    case 'enterprise':
                        data.enterprise.options = resp.data.items[0];
                        break;
                    default:
                        console.log('undefined tier ' + tier);
                }
                return callback;
            }
        )
     .catch(error => {
            console.log(error)
        })
     .finally(() => { 
            //console.log(data);
        })
}

