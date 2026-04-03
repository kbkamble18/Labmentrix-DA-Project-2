import streamlit as st
import pandas as pd
import plotly.express as px

st.set_page_config(page_title="Bird Species Observation Dashboard", layout="wide")

st.title(" Bird Species Observation Analysis")
st.markdown(
    "**Comprehensive Analysis of Bird Distribution, Habitat Preference, and Environmental Impact in Forest & Grassland**"
)


# Load Data
@st.cache_data
def load_data():
    df = pd.read_csv("Cleaned_Bird_Observation_Data.csv", low_memory=False)
    df["Date"] = pd.to_datetime(df["Date"], errors="coerce")
    df["Year"] = df["Date"].dt.year
    df["Month"] = df["Date"].dt.month
    df["Season"] = (
        df["Month"]
        .map(
            {
                12: "Winter",
                1: "Winter",
                2: "Winter",
                3: "Spring",
                4: "Spring",
                5: "Spring",
                6: "Summer",
                7: "Summer",
                8: "Summer",
                9: "Fall",
                10: "Fall",
                11: "Fall",
            }
        )
        .fillna("Unknown")
    )
    return df


df = load_data()

# Sidebar Filters
st.sidebar.header(" Filters")
habitat_filter = st.sidebar.multiselect(
    "Habitat", options=df["Habitat"].unique(), default=df["Habitat"].unique()
)
admin_filter = st.sidebar.multiselect(
    "Admin Unit",
    options=sorted(df["Admin_Unit_Code"].unique()),
    default=df["Admin_Unit_Code"].unique(),
)
season_filter = st.sidebar.multiselect(
    "Season", options=sorted(df["Season"].unique()), default=df["Season"].unique()
)

filtered_df = df[
    df["Habitat"].isin(habitat_filter)
    & df["Admin_Unit_Code"].isin(admin_filter)
    & df["Season"].isin(season_filter)
]

# Key Metrics
col1, col2, col3, col4, col5 = st.columns(5)
col1.metric("Total Observations", f"{len(filtered_df):,}")
col2.metric("Unique Species", filtered_df["Scientific_Name"].nunique())
col3.metric("Forest Observations", len(filtered_df[filtered_df["Habitat"] == "Forest"]))
col4.metric(
    "Grassland Observations", len(filtered_df[filtered_df["Habitat"] == "Grassland"])
)
col5.metric("Unique Admin Units", filtered_df["Admin_Unit_Code"].nunique())

# Tabs with 18+ EDAs
tab1, tab2, tab3, tab4, tab5 = st.tabs(
    [
        " Habitat Overview",
        " Species Analysis",
        " Hotspots & Spatial",
        " Temporal Trends",
        " Environment & Conservation",
    ]
)

with tab1:
    st.subheader("Habitat Comparison")
    habitat_summary = (
        filtered_df.groupby("Habitat")
        .agg(
            {
                "Scientific_Name": "nunique",
                "Common_Name": "count",
                "Plot_Name": "nunique",
            }
        )
        .rename(
            columns={
                "Scientific_Name": "Unique Species",
                "Common_Name": "Observations",
                "Plot_Name": "Unique Plots",
            }
        )
    )

    fig1 = px.bar(
        habitat_summary.reset_index(),
        x="Habitat",
        y=["Unique Species", "Observations", "Unique Plots"],
        barmode="group",
        title="Forest vs Grassland Comparison",
    )
    st.plotly_chart(fig1, use_container_width=True)

with tab2:
    st.subheader("Species Analysis")
    c1, c2 = st.columns(2)

    with c1:
        st.write("**Top 15 Most Observed Species**")
        top_species = filtered_df["Common_Name"].value_counts().head(15)
        fig2 = px.bar(
            top_species.reset_index(),
            x="Common_Name",
            y="count",
            title="Top 15 Species",
        )
        st.plotly_chart(fig2, use_container_width=True)

    with c2:
        st.write("**Species Preference by Habitat**")
        top_habitat = (
            filtered_df.groupby(["Habitat", "Common_Name"])
            .size()
            .reset_index(name="Count")
        )
        top_habitat = (
            top_habitat.sort_values(["Habitat", "Count"], ascending=[True, False])
            .groupby("Habitat")
            .head(10)
        )
        fig3 = px.bar(
            top_habitat,
            x="Common_Name",
            y="Count",
            color="Habitat",
            title="Species Preference: Forest vs Grassland",
        )
        st.plotly_chart(fig3, use_container_width=True)

with tab3:
    st.subheader("Biodiversity Hotspots & Spatial Analysis")
    hotspots = (
        filtered_df.groupby(["Admin_Unit_Code", "Habitat"])
        .agg({"Common_Name": "count", "Scientific_Name": "nunique"})
        .rename(
            columns={"Common_Name": "Observations", "Scientific_Name": "Unique Species"}
        )
        .reset_index()
    )

    fig4 = px.bar(
        hotspots.sort_values("Observations", ascending=False).head(15),
        x="Admin_Unit_Code",
        y="Observations",
        color="Habitat",
        title="Top 15 Biodiversity Hotspots",
    )
    st.plotly_chart(fig4, use_container_width=True)

    # Distance Analysis
    st.subheader("Distance Analysis")
    distance_analysis = (
        filtered_df.groupby(["Distance", "Habitat"])
        .size()
        .reset_index(name="Observations")
    )
    fig5 = px.bar(
        distance_analysis,
        x="Distance",
        y="Observations",
        color="Habitat",
        title="Observations by Distance Category",
    )
    st.plotly_chart(fig5, use_container_width=True)

with tab4:
    st.subheader("Temporal Trends")
    seasonal = (
        filtered_df.groupby(["Season", "Habitat"])["Common_Name"]
        .count()
        .reset_index(name="Observations")
    )
    fig6 = px.line(
        seasonal,
        x="Season",
        y="Observations",
        color="Habitat",
        markers=True,
        title="Seasonal Observation Trends",
    )
    st.plotly_chart(fig6, use_container_width=True)

    # Monthly Trend
    monthly = (
        filtered_df.groupby(["Month", "Habitat"])["Common_Name"]
        .count()
        .reset_index(name="Observations")
    )
    fig7 = px.line(
        monthly,
        x="Month",
        y="Observations",
        color="Habitat",
        markers=True,
        title="Monthly Observation Pattern",
    )
    st.plotly_chart(fig7, use_container_width=True)

with tab5:
    st.subheader("Environment & Conservation")

    # Weather Impact
    st.write("**Weather Impact Analysis**")
    weather = (
        filtered_df.groupby(["Sky", "Habitat"])["Common_Name"]
        .count()
        .reset_index(name="Observations")
    )
    fig8 = px.bar(
        weather,
        x="Sky",
        y="Observations",
        color="Habitat",
        title="Weather Impact on Bird Activity",
    )
    st.plotly_chart(fig8, use_container_width=True)

    # Conservation
    st.write("**Conservation Insights (PIF Watchlist)**")
    watchlist = filtered_df[filtered_df["PIF_Watchlist_Status"] : True]
    st.metric("Total At-Risk Observations", len(watchlist))

    if not watchlist.empty:
        fig9 = px.bar(
            watchlist["Common_Name"].value_counts().head(10).reset_index(),
            x="Common_Name",
            y="count",
            title="Top At-Risk Species",
        )
        st.plotly_chart(fig9, use_container_width=True)

    # Flyover & ID Method
    col_a, col_b = st.columns(2)
    with col_a:
        st.write("**Flyover Frequency**")
        flyover = (
            filtered_df.groupby(["Flyover_Observed", "Habitat"])
            .size()
            .reset_index(name="Count")
        )
        fig10 = px.bar(
            flyover,
            x="Flyover_Observed",
            y="Count",
            color="Habitat",
            title="Flyover Analysis",
        )
        st.plotly_chart(fig10, use_container_width=True)

    with col_b:
        st.write("**Identification Method**")
        id_method = (
            filtered_df.groupby(["ID_Method", "Habitat"])
            .size()
            .reset_index(name="Count")
        )
        fig11 = px.bar(
            id_method,
            x="ID_Method",
            y="Count",
            color="Habitat",
            title="ID Method Analysis",
        )
        st.plotly_chart(fig11, use_container_width=True)

# Footer
st.markdown("---")
st.caption(
    "Bird Species Observation Analysis | 18+ EDA | Data Cleaning → PostgreSQL → Interactive Streamlit Dashboard"
)

st.sidebar.info(
    "Dashboard includes 18+ Exploratory Data Analyses as per project requirements."
)
