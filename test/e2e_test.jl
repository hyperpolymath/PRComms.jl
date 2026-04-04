# SPDX-License-Identifier: MPL-2.0
# (PMPL-1.0-or-later preferred; MPL-2.0 required for Julia ecosystem)
# E2E pipeline tests for PRComms.jl

using Test
using PRComms
using Dates

@testset "E2E Pipeline Tests" begin

    @testset "Full comms campaign pipeline" begin
        # Create pillar → variant → press release → publish
        pillar = create_pillar(:camp_p, "Product Launch",
                               ["Revolutionary AI feature", "Available now globally"])
        @test pillar isa MessagePillar

        variant = generate_variant(pillar, :customers, :twitter; tone=:bold)
        @test variant isa AudienceVariant
        @test variant.pillar_id == :camp_p

        pr = draft_release(:camp_pr, "Big Launch Today", "We launch our product.")
        review_release(pr)
        @test pr.status == :review

        result = publish_release(pr)
        @test pr.status == :published
        @test occursin("LIVE", result)
    end

    @testset "Crisis management pipeline" begin
        playbook = CrisisPlaybook(:crisis_e2e, :data_breach, 5,
                                  ["We are investigating.", "Update in 2 hours.", "Resolved."],
                                  ["CISO", "CEO", "Legal", "Comms"])

        result = activate_crisis_mode(playbook)
        @test result isa String
        @test occursin("Incident Management", result)

        stmt1 = issue_holding_statement(playbook, 1)
        @test occursin("We are investigating.", stmt1)

        stmt3 = issue_holding_statement(playbook, 3)
        @test occursin("Resolved.", stmt3)
    end

    @testset "CommsPlan milestone pipeline" begin
        plan = CommsPlan(:e2e_plan, "Q3 Campaign")
        add_milestone(plan, Date(2026, 7, 1), :linkedin, "Teaser", "Alice")
        add_milestone(plan, Date(2026, 8, 1), :twitter, "Launch", "Bob")
        add_milestone(plan, Date(2026, 6, 15), :press_release, "Pre-announcement", "Charlie")

        @test nrow(plan.timeline) == 3
        # Should be sorted by date
        @test plan.timeline.Date[1] == Date(2026, 6, 15)
        @test plan.timeline.Date[3] == Date(2026, 8, 1)
    end

    @testset "Error handling: holding statement out of bounds" begin
        playbook = CrisisPlaybook(:err_pb, :flood, 1, ["Only statement"], ["Ops"])
        @test_throws BoundsError issue_holding_statement(playbook, 5)
    end

end
