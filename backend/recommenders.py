# recommenders.py

from joblib import load
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity

class Recommender:
    def __init__(self, model_path):
        # Carrega o modelo e os dados
        recomendation_dict = load(model_path)
        self.perfis_usuarios = recomendation_dict["perfis_usuarios"]
        self.df = recomendation_dict["df"]

    def top_recommendations(self, user_id, topn=5):
        # Obtém o perfil-alvo
        perfil_alvo = pd.DataFrame([self.perfis_usuarios[user_id]])

        # Calcula as similaridades
        cols_generos = self.df.loc[:, 'Action':'Western'].columns
        filmes = self.df[cols_generos].drop_duplicates()

        similaridades = cosine_similarity(perfil_alvo, filmes)

        recomendacoes = pd.DataFrame({
            'id': filmes.index,
            'filme': self.df.iloc[filmes.index]['nome'],
            'similaridade': similaridades[0]
        })
        recomendacoes = recomendacoes.sort_values(by='similaridade', ascending=False)

        # Seleciona os filmes que o usuário assistiu
        filmes_assistidos_df = self.df[self.df['id_usuario'] == user_id]['id_filme'].tolist()

        # Obtém a lista de recomendações de filmes que o usuário não assistiu ainda
        filmes_recomendados_df = recomendacoes[~recomendacoes['id'].isin(filmes_assistidos_df)]

        mais_similares_df = filmes_recomendados_df.head(topn)
        return mais_similares_df.to_json(orient="records")
