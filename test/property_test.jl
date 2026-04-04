# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# Property-based invariant tests for PRComms.jl

using Test
using PRComms

@testset "Property-Based Tests" begin

    @testset "Invariant: calc_nps is in [-100, 100]" begin
        for _ in 1:50
            n = rand(1:50)
            scores = rand(1:10, n)
            sr = SurveyResult(:prop_nps, "Test", n, scores, String[])
            nps = calc_nps(sr)
            @test -100.0 <= nps <= 100.0
        end
    end

    @testset "Invariant: share_of_voice is in [0, 100]" begin
        for _ in 1:50
            total = rand(1:10000)
            brand = rand(0:total)
            sov = share_of_voice(brand, total)
            @test 0.0 <= sov <= 100.0
        end
    end

    @testset "Invariant: brand_equity_valuation is positive for positive revenue" begin
        for _ in 1:50
            revenue = rand(1.0:1.0:1_000_000.0)
            strength = rand()
            result = brand_equity_valuation(revenue, strength)
            @test result.value > 0
            @test 1.0 <= result.royalty_rate_percent <= 5.0
        end
    end

    @testset "Invariant: generate_variant body includes audience type" begin
        for aud in [:investors, :customers, :employees, :media]
            pillar = create_pillar(:prop_p, "Test Theme", ["Point A", "Point B"])
            variant = generate_variant(pillar, aud, :linkedin)
            @test occursin(string(aud), variant.body)
        end
    end

    @testset "Invariant: draft_release always starts as draft" begin
        for _ in 1:50
            id = Symbol("pr$(rand(1:99999))")
            pr = draft_release(id, "Title $(rand(1:99999))", "Body text")
            @test pr.status == :draft
            @test pr.embargo_at === nothing
        end
    end

end
