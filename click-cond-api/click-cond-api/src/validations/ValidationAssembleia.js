var yup = require('yup');

module.exports = {

	async validateInsertAssembleia(req, res, next) {
		try {
			const schema = yup.object().shape({
				titulo: yup.string().required('Informe o título'),
				descricao: yup.string().required('Informe a descrição.'),
                data: yup.string().required('Informe a data.'),
				hora: yup.string().required('Informe a hora.'),
				local: yup.string().required('Informe o local.'),
			});

			await schema.validate(req.body.assembleia, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},

	async validateInsertVotacao(req, res, next) {
		try {
			const schema = yup.object().shape({
				titulo: yup.string().required('Informe o título'),
				data_inicio: yup.string().required('Informe a data de início.'),
                data_termino: yup.string().required('Informe a data de término.'),
			});

			await schema.validate(req.body.votacao, { abortEarly: false });
			next();
		} catch (error) {
			var message = '';
			error.inner.forEach(e => { message += e.message + '\n'; });
			return res.status(400).json({ message: message });
		}
	},
	
};
