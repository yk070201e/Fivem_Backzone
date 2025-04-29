local zones = {
    {
        points = {
            vector3(-3457.9130859375, -3754.712890625, 884.32476806641 - 1),
            vector3(-3483.2565917969, -3810.3232421875, 884.32476806641 - 1),
            vector3(-3498.4060058594, -3817.1313476562, 884.32476806641 - 1),
            vector3(-3520.9453125, -3811.7368164062, 884.32476806641 - 1),
            vector3(-3576.8154296875, -3795.9086914062, 884.32476806641 - 1),
            vector3(-3555.8215332031, -3750.0043945312, 884.32476806641 - 1),
            vector3(-3539.5270996094, -3713.8239746094, 885.32489013672 - 1)
        }
    }
}

-- 안전한 좌표 (플레이어가 떨어질 때 TP될 위치)
local safeCoords = vector3(-3553.5285644531, -3744.7348632812, 886.66931152344)

-- 스크립트 작동 플래그
local isMonitoring = true
local hasShownMessage = false  -- 메시지가 이미 표시되었는지 여부

-- 최대 허용 거리 (이 거리 이상 떨어지면 스크립트 중단)
local maxDistance = 500.0

-- 기준점 (zones[1]의 첫 번째 포인트 사용)
local centerPoint = vector3(zones[1].points[1].x, zones[1].points[1].y, zones[1].points[1].z)

-- 주기적으로 플레이어의 위치를 감시하여 구역을 벗어났는지 확인
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)  -- 0.5초마다 체크

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInZone = isPointInPolygon(playerCoords, zones[1].points)
        local distanceFromCenter = #(centerPoint - playerCoords)

        -- 플레이어가 최대 허용 거리 이상 떨어지면 스크립트 중단
        if distanceFromCenter > maxDistance then
            if isMonitoring then
                isMonitoring = false
                if not hasShownMessage then
                    TriggerEvent('chat:addMessage', {
                        multiline = true,
                        template = '<span class="chatIcon system">시스템</span> {0}',
                        args = {"RP구역 존에서 멀리 떨어져 TP가 중단 되었습니다."}
                    })
                    hasShownMessage = true  -- 메시지를 한 번만 출력하도록 설정
                end
            end
        else
            -- 플레이어가 구역 안이나 최대 거리 내에 있을 때 감시 활성화
            if not isMonitoring then
                isMonitoring = true
                hasShownMessage = false  -- 다시 구역 안에 들어오면 메시지 초기화
            end
        end

        -- 플레이어가 구역을 벗어났을 때 즉시 복귀
        if isMonitoring and not isInZone then
            SetEntityCoords(playerPed, safeCoords.x, safeCoords.y, safeCoords.z)
            TriggerEvent('chat:addMessage', {
                multiline = true,
                template = '<span class="chatIcon system">시스템</span> {0}',
                args = {"RP구역 존을 벗어나 존으로 복귀 되었습니다."}
            })
        end
    end
end)

-- 다각형 내부에 점이 있는지 확인하는 함수 (포인트 인 폴리곤 알고리즘)
function isPointInPolygon(point, polygon)
    local isInside = false
    local j = #polygon

    for i = 1, #polygon do
        if ((polygon[i].y > point.y) ~= (polygon[j].y > point.y)) and
           (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x) then
            isInside = not isInside
        end
        j = i
    end

    return isInside
end
