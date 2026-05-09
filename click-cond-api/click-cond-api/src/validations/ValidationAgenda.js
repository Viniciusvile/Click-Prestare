var yup = require('yup');

module.exports = {

	async validateInsertAgenda(req, res, next) {
		try {
			const schema = yup.object().shape({
				titulo: yup.string().required('Informe o título.'),
				descricao: yup.string().required('Informe a descrição.'),
                data_inicio: yup.string().required('Informe a data de início.'),
				data_termino: yup.string().required('Informe a data de término.'),
				hora_inicio: yup.string().required('Informe a hora de início'),
				hora_termino: yup.string().required('Informe a hora de término'),
			});

			await schema.validate(req.body.agenda, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
};
