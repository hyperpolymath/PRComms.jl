# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# BenchmarkTools benchmarks for PRComms.jl

using BenchmarkTools
using PRComms
using Dates

const SUITE = BenchmarkGroup()

SUITE["messaging"] = BenchmarkGroup()

SUITE["messaging"]["create_pillar"] = @benchmarkable create_pillar(:bp, "Theme", ["P1", "P2"])

SUITE["messaging"]["generate_variant"] = let
    pillar = create_pillar(:bench_p, "Sustainability", ["Net zero by 2030"])
    @benchmarkable generate_variant($pillar, :investors, :linkedin)
end

SUITE["newsroom"] = BenchmarkGroup()

SUITE["newsroom"]["draft_release"] = @benchmarkable draft_release(:bench_pr, "Title", "Body")

SUITE["newsroom"]["publish_pipeline"] = @benchmarkable begin
    pr = draft_release(:bench_pr2, "Title", "Body")
    review_release(pr)
    publish_release(pr)
end

SUITE["analytics"] = BenchmarkGroup()

SUITE["analytics"]["calc_nps_100"] = let
    sr = SurveyResult(:bench_nps, "NPS", 100, rand(1:10, 100), String[])
    @benchmarkable calc_nps($sr)
end

SUITE["analytics"]["brand_equity"] = @benchmarkable brand_equity_valuation(1_000_000.0, 0.7)

SUITE["strategy"] = BenchmarkGroup()

SUITE["strategy"]["add_milestone_10"] = let
    plan = CommsPlan(:bench_plan, "Bench Plan")
    @benchmarkable add_milestone($plan, Date(2026, rand(1:12), 1), :twitter, "Msg", "Owner") setup=(plan = CommsPlan(:bp2, "Bench"))
end

if abspath(PROGRAM_FILE) == @__FILE__
    tune!(SUITE)
    results = run(SUITE, verbose=true)
    BenchmarkTools.save("benchmarks_results.json", results)
end
