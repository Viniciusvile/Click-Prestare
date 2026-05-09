var yup = require('yup');

module.exports = {

	async validateInsert(req, res, next) {
		try {
			const schema = yup.object().shape({
				hora_inicio: yup.string().required('Informe o horário desejado.'),
				data: yup.string().required('Informe a data.'),
				id_apartamento: yup.number().required('Informe o apartamento'),
			});

			await schema.validate(req.body.mudanca, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
