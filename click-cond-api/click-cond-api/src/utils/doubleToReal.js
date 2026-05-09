module.exports = {

	convertDoubleToReal: function (value) {
		return value.toLocaleString('pt-br', { style: 'currency', currency: 'BRL' });
	}

};


