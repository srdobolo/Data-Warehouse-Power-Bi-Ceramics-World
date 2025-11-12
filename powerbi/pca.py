import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from matplotlib.patches import Ellipse

# =======================================
# 1. Load and prepare dataset
# =======================================
df = dataset.copy()
df = df[['gdp_per_capita_usd', 'value_2024_usd', 'urban_population_total']].copy()

# Convert all columns to numeric
df = df.apply(pd.to_numeric, errors='coerce')

# Fill missing values with each column's mean (PCA-safe)
df = df.fillna(df.mean())

print("Data shape after cleaning:", df.shape)
print("Any NaNs left?", df.isna().sum().sum())

# =======================================
# 2. Validate dataset size
# =======================================
if df.shape[0] < 2 or df.shape[1] < 2:
    print(f"⚠️ Not enough data for PCA (got {df.shape[0]} samples). Displaying raw data instead.")
    sns.pairplot(df)
    plt.suptitle("Raw Data (PCA skipped: not enough samples)", fontsize=14)
    plt.show()
else:
    # =======================================
    # 3. Standardize and apply PCA
    # =======================================
    X_scaled = StandardScaler().fit_transform(df)

    pca = PCA(n_components=2)
    X_pca = pca.fit_transform(X_scaled)

    loadings = pca.components_.T * np.sqrt(pca.explained_variance_)
    feature_names = df.columns

    # Create DataFrame for visualization
    pca_df = pd.DataFrame(X_pca, columns=['PCA1', 'PCA2'])
    pca_df['gdp_per_capita_usd'] = df['gdp_per_capita_usd'].values
    pca_df['urban_population_total'] = df['urban_population_total'].values

    # =======================================
    # 4. Helper: draw ellipse for groups
    # =======================================
    def draw_ellipse(data, ax, group_col, value, color, alpha=0.2):
        subset = data[data[group_col] == value][['PCA1', 'PCA2']]
        if len(subset) < 2:
            return
        mean = subset.mean().values
        cov = np.cov(subset.T)

        eigenvals, eigenvecs = np.linalg.eigh(cov)
        order = eigenvals.argsort()[::-1]
        eigenvals, eigenvecs = eigenvals[order], eigenvecs[:, order]

        angle = np.degrees(np.arctan2(*eigenvecs[:, 0][::-1]))
        width, height = 2 * np.sqrt(eigenvals) * 2  # 95% confidence ellipse

        ellipse = Ellipse(
            xy=mean,
            width=width,
            height=height,
            angle=angle,
            edgecolor=color,
            facecolor=color,
            alpha=alpha,
            linewidth=2
        )
        ax.add_patch(ellipse)

    # =======================================
    # 5. Plot PCA results
    # =======================================
    fig, ax = plt.subplots(figsize=(14, 10))

    sns.scatterplot(
        data=pca_df,
        x='PCA1',
        y='PCA2',
        hue='gdp_per_capita_usd',
        style='urban_population_total',
        palette='Set1',
        s=120,
        alpha=0.85,
        edgecolor='k',
        linewidth=0.6,
        ax=ax
    )

    # Arrows for feature loadings
    scale_factor = 1.5
    for i, feature in enumerate(feature_names):
        ax.arrow(0, 0,
                 loadings[i, 0] * scale_factor,
                 loadings[i, 1] * scale_factor,
                 head_width=0.1, head_length=0.1,
                 fc='green', ec='green', lw=2.5, zorder=10)
        ax.text(loadings[i, 0] * 1.7,
                loadings[i, 1] * 1.7,
                feature, color='green', fontsize=12, ha='center', weight='bold')

    # Titles and labels
    ax.set_title('PCA: Projection with Loadings and Group Ellipses', fontsize=16, pad=20)
    ax.set_xlabel(f'PCA1 - {pca.explained_variance_ratio_[0]:.1%} of variance', fontsize=12)
    ax.set_ylabel(f'PCA2 - {pca.explained_variance_ratio_[1]:.1%} of variance', fontsize=12)
    ax.axhline(0, color='gray', linestyle='-', alpha=0.3)
    ax.axvline(0, color='gray', linestyle='-', alpha=0.3)
    ax.grid(True, alpha=0.2)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left', frameon=True)
    plt.tight_layout()
    plt.show()