module.exports = {

	convertMonthToReal: function (number, abreviar) {
		var months = [ "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", 
           "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" ];
		return abreviar ? months[number-1].substring(0,3) : months[number-1];
	},

	formatDateToString: function (date) {
		return [
			this.padTo2Digits(date.getDate()),
			this.padTo2Digits(date.getMonth() + 1),
			date.getFullYear(),
		].join('/');
	},
	
	padTo2Digits: function (num) {
		return num.toString().padStart(2, '0');
	}

};


