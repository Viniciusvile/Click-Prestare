var yup = require('yup');

module.exports = {

	async validateInsertAreaSocial(req, res, next) {
		try {
			const schema = yup.object().shape({
				nome: yup.string().required('Informe o nome da área social.'),
				agendar: yup.string().required('Informe se será necessário agendamento.'),
                imagem: yup.string().required('Selecione uma imagem.').nullable(),
				capacidade: yup.number().required('Informe a capacidade de pessoas suportado.'),
			});

			await schema.validate(req.body.areaSocial, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

    async validateInsertAgendamento(req, res, next) {
		try {
			const schema = yup.object().shape({
				id: yup.number().required('Id não identificado.'),
                id_apartamento: yup.number().transform((value) => Number.isNaN(value) ? null : value ).nullable().required('Selecione o Bloco e o Apartamento para vincular a reserva.'),
				data: yup.string().required('Selecione a data desejada.'),
                horaDe: yup.string().required('Selecione o horário desejado.'),
			});

			await schema.validate(req.body.agendamento, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
