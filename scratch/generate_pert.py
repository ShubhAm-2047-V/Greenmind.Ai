import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Create a figure and axis with a cream background to match the theme
fig, ax = plt.subplots(figsize=(12, 6.5), dpi=300)
fig.patch.set_facecolor('#FFFCEE')  # GreenMind cream background
ax.set_facecolor('#FFFCEE')

# Define nodes: (id, name, duration, x, y)
nodes = {
    1: {"name": "Project Initiation\n(Month 1)", "dur": "1m", "x": 0.5, "y": 3.0},
    2: {"name": "ML Model Training\n& Curation", "dur": "7m", "x": 2.5, "y": 4.5},
    3: {"name": "FastAPI Backend\n& DB Setup", "dur": "6m", "x": 2.5, "y": 1.5},
    4: {"name": "Flutter App UI\n& Integration", "dur": "8m", "x": 5.0, "y": 3.0},
    5: {"name": "System Integration\n& Local Test", "dur": "6m", "x": 7.5, "y": 3.0},
    6: {"name": "Field Deployment\n& Model Tuning", "dur": "6m", "x": 9.8, "y": 4.5},
    7: {"name": "Final Release\n& Auditing", "dur": "4m", "x": 9.8, "y": 1.5},
    8: {"name": "Project Closure\n(Month 36)", "dur": "2m", "x": 11.5, "y": 3.0}
}

# Define dependencies (edges): (from, to, description)
edges = [
    (1, 2, "Start ML"),
    (1, 3, "Start Backend"),
    (2, 4, "Model Ready"),
    (3, 4, "APIs Ready"),
    (4, 5, "App Draft"),
    (5, 6, "Stable Beta"),
    (5, 7, "Security Prep"),
    (6, 8, "Field Data"),
    (7, 8, "Compliance")
]

# Draw edges (arrows)
for edge in edges:
    u, v, label = edge
    x1, y1 = nodes[u]["x"], nodes[u]["y"]
    x2, y2 = nodes[v]["x"], nodes[v]["y"]
    
    # Calculate arrow offset so it doesn't touch the node text box exactly
    dx = x2 - x1
    dy = y2 - y1
    dist = (dx**2 + dy**2)**0.5
    
    # Scale offset based on box size
    ox = 0.8 * dx / dist
    oy = 0.4 * dy / dist
    
    # Draw arrow
    ax.annotate(
        "",
        xy=(x2 - ox, y2 - oy),
        xytext=(x1 + ox, y1 + oy),
        arrowprops=dict(
            arrowstyle="-|>",
            color="#2E7D32", # GreenMind forest green
            lw=2.5,
            mutation_scale=20
        )
    )
    
    # Label on arrow
    mid_x = (x1 + x2) / 2
    mid_y = (y1 + y2) / 2
    ax.text(
        mid_x,
        mid_y + 0.15,
        f"{nodes[u]['dur']}",
        color="#1B5E20",
        fontsize=10,
        fontweight="bold",
        ha="center",
        va="center",
        bbox=dict(boxstyle="round,pad=0.2", fc="#E8F5E9", ec="none", alpha=0.9)
    )

# Draw nodes (boxes)
for nid, info in nodes.items():
    # Draw text box
    ax.text(
        info["x"],
        info["y"],
        f"ID: P{nid}\n{info['name']}",
        fontsize=10,
        fontweight="bold",
        color="#ffffff" if nid in [1, 8] else "#1B5E20",
        ha="center",
        va="center",
        bbox=dict(
            boxstyle="round,pad=0.5",
            fc="#1B5E20" if nid in [1, 8] else "#E8F5E9",  # Accent fill
            ec="#2E7D32",  # Forest green border
            lw=2
        )
    )

# Set chart titles and limits
ax.set_title("GreenMind AI: PERT Network Diagram (36-Month Timeline)", fontsize=16, fontweight="bold", color="#1B5E20", pad=20)
ax.set_xlim(-0.5, 12.5)
ax.set_ylim(0.5, 5.5)
ax.axis("off")

# Save the plot
plt.tight_layout()
plt.savefig(r"e:\GreenMind al\scratch\pert_chart.png", facecolor='#FFFCEE', bbox_inches="tight", dpi=300)
plt.close()
print("PERT chart generated successfully.")
